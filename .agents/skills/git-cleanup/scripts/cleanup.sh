#!/usr/bin/env bash

set -euo pipefail

# ==============================================================================
# Git Cleanup Script
# 安全に不要なローカルブランチ、Worktree、リモートブランチを検知・削除します。
# ==============================================================================

# カラー定義
if [[ -t 1 ]]; then
  COLOR_RED="\033[0;31m"
  COLOR_GREEN="\033[0;32m"
  COLOR_YELLOW="\033[0;33m"
  COLOR_BLUE="\033[0;34m"
  COLOR_CYAN="\033[0;36m"
  COLOR_GRAY="\033[0;90m"
  COLOR_BOLD="\033[1m"
  COLOR_RESET="\033[0m"
else
  COLOR_RED=""
  COLOR_GREEN=""
  COLOR_YELLOW=""
  COLOR_BLUE=""
  COLOR_CYAN=""
  COLOR_GRAY=""
  COLOR_BOLD=""
  COLOR_RESET=""
fi

# オプション初期値
MODE="dry-run"
INCLUDE_REMOTE=true
OUTPUT_JSON=false
TARGET_DIR="."

# 保護ブランチパターン（正規表現）
PROTECTED_PATTERNS=("^main$" "^master$" "^develop$" "^development$" "^release/.*" "^staging$" "^production$")

# ヘルプ表示
show_help() {
  cat << 'EOF'
使用方法: cleanup.sh [OPTIONS]

不要になったローカルブランチ、Git worktree、リモートブランチを安全に検知・削除します。

オプション:
  -n, --dry-run         削除候補の一覧表示のみを行い、実際の削除は行いません (デフォルト)
  -e, --execute         安全チェックを通過した対象を実際に削除します
  -l, --local-only      リモートブランチを除外し、ローカルブランチ/Worktreeのみを対象とします
  -r, --include-remote  リモートブランチも含めて対象とします (デフォルト)
  -j, --json            結果を JSON 形式で出力します
  -C, --dir <PATH>      対象のリポジトリディレクトリを指定します (デフォルト: カレントディレクトリ)
  -h, --help            このヘルプメッセージを表示します

安全設計:
  - main, master, develop, release/*, staging, production, および現在のブランチは自動保護されます。
  - 未コミット・未追跡の変更がある Worktree は自動でスキップされ、紐づくブランチも保持されます。
EOF
}

# 引数解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      MODE="dry-run"
      shift
      ;;
    -e|--execute)
      MODE="execute"
      shift
      ;;
    -l|--local-only)
      INCLUDE_REMOTE=false
      shift
      ;;
    -r|--include-remote)
      INCLUDE_REMOTE=true
      shift
      ;;
    -j|--json)
      OUTPUT_JSON=true
      shift
      ;;
    -C|--dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo -e "${COLOR_RED}エラー: 不明なオプション '$1'${COLOR_RESET}" >&2
      show_help
      exit 1
      ;;
  esac
done

cd "$TARGET_DIR"

# Git リポジトリ内か確認
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo -e "${COLOR_RED}エラー: 指定されたディレクトリは Git リポジトリではありません: $(pwd)${COLOR_RESET}" >&2
  exit 1
fi

GIT_ROOT="$(cd "$(git rev-parse --show-toplevel)" && pwd -P)"
cd "$GIT_ROOT"

# リモート情報の最新化 (origin が存在する場合)
if git remote | grep -q "^origin$"; then
  git fetch --prune origin >/dev/null 2>&1 || true
fi

# デフォルトブランチの判定
get_default_branch() {
  local def_branch=""
  if git symbolic-ref refs/remotes/origin/HEAD >/dev/null 2>&1; then
    def_branch="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
  fi

  if [[ -z "$def_branch" ]]; then
    if git show-ref --verify --quiet refs/heads/main; then
      def_branch="main"
    elif git show-ref --verify --quiet refs/heads/master; then
      def_branch="master"
    else
      def_branch="$(git branch --show-current 2>/dev/null || echo "main")"
    fi
  fi
  echo "$def_branch"
}

DEFAULT_BRANCH="$(get_default_branch)"
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "")"

# 保護ブランチか判定する関数
is_protected_branch() {
  local branch="$1"
  if [[ "$branch" == "$CURRENT_BRANCH" ]]; then
    return 0
  fi
  for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$branch" =~ $pattern ]]; then
      return 0
    fi
  done
  return 1
}

# 1. Worktree の一覧と状態の取得
WORKTREE_TEMP="$(mktemp)"
trap 'rm -f "$WORKTREE_TEMP"' EXIT

git worktree list --porcelain > "$WORKTREE_TEMP"

WT_PATHS=()
WT_BRANCHES=()
WT_DIRTIES=()

parse_worktrees() {
  local cur_path=""
  local cur_branch=""
  local cur_bare=false

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^worktree\ (.*) ]]; then
      cur_path="${BASH_REMATCH[1]}"
      cur_branch=""
      cur_bare=false
    elif [[ "$line" =~ ^branch\ refs/heads/(.*) ]]; then
      cur_branch="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^bare ]]; then
      cur_bare=true
    elif [[ -z "$line" ]]; then
      if [[ -n "$cur_path" && "$cur_bare" == false ]]; then
        local norm_path
        norm_path="$(cd "$cur_path" 2>/dev/null && pwd -P || echo "$cur_path")"
        if [[ "$norm_path" != "$GIT_ROOT" ]]; then
          local is_dirty="clean"
          if [[ -d "$cur_path" ]]; then
            local dirty_status
            dirty_status="$(git -C "$cur_path" status --porcelain 2>/dev/null || echo "")"
            if [[ -n "$dirty_status" ]]; then
              is_dirty="dirty"
            fi
          else
            is_dirty="missing"
          fi
          WT_PATHS+=("$cur_path")
          WT_BRANCHES+=("$cur_branch")
          WT_DIRTIES+=("$is_dirty")
        fi
      fi
      cur_path=""
      cur_branch=""
      cur_bare=false
    fi
  done < "$WORKTREE_TEMP"

  if [[ -n "$cur_path" && "$cur_bare" == false ]]; then
    local norm_path
    norm_path="$(cd "$cur_path" 2>/dev/null && pwd -P || echo "$cur_path")"
    if [[ "$norm_path" != "$GIT_ROOT" ]]; then
      local is_dirty="clean"
      if [[ -d "$cur_path" ]]; then
        local dirty_status
        dirty_status="$(git -C "$cur_path" status --porcelain 2>/dev/null || echo "")"
        if [[ -n "$dirty_status" ]]; then
          is_dirty="dirty"
        fi
      else
        is_dirty="missing"
      fi
      WT_PATHS+=("$cur_path")
      WT_BRANCHES+=("$cur_branch")
      WT_DIRTIES+=("$is_dirty")
    fi
  fi
}

parse_worktrees

get_branch_worktree_status() {
  local branch="$1"
  if [[ ${#WT_BRANCHES[@]} -eq 0 ]]; then
    echo "none:"
    return 0
  fi
  local idx=0
  for b in "${WT_BRANCHES[@]}"; do
    if [[ "$b" == "$branch" ]]; then
      local d="${WT_DIRTIES[$idx]}"
      if [[ "$d" == "dirty" ]]; then
        echo "dirty:${WT_PATHS[$idx]}"
        return 0
      else
        echo "clean:${WT_PATHS[$idx]}"
        return 0
      fi
    fi
    ((idx++))
  done
  echo "none:"
  return 0
}

# 2. ローカルブランチの判定
CANDIDATE_BRANCHES=()
CANDIDATE_REASONS=()
CANDIDATE_WT_PATHS=()
SKIPPED_BRANCHES=()
SKIPPED_REASONS=()

# マージ済みブランチの収集 (+ は worktree でチェックアウト中のプレフィックス)
MERGED_BRANCHES_RAW="$(git branch --merged "$DEFAULT_BRANCH" 2>/dev/null | sed 's/^[ *+]*//' || true)"

# gone ブランチの収集
GONE_BRANCHES_RAW="$(git branch -vv 2>/dev/null | grep ': gone]' | sed 's/^[ *+]*//' | awk '{print $1}' || true)"

# すべてのローカルブランチ一覧
ALL_LOCAL_BRANCHES="$(git branch --format='%(refname:short)' 2>/dev/null || true)"

while IFS= read -r branch; do
  [[ -z "$branch" ]] && continue

  if is_protected_branch "$branch"; then
    continue
  fi

  reason=""
  if echo "$MERGED_BRANCHES_RAW" | grep -qx "$branch"; then
    reason="merged (into $DEFAULT_BRANCH)"
  elif echo "$GONE_BRANCHES_RAW" | grep -qx "$branch"; then
    reason="gone (remote deleted)"
  fi

  if [[ -n "$reason" ]]; then
    wt_info="$(get_branch_worktree_status "$branch")"
    wt_status="${wt_info%%:*}"
    wt_path="${wt_info#*:}"

    if [[ "$wt_status" == "dirty" ]]; then
      SKIPPED_BRANCHES+=("$branch")
      SKIPPED_REASONS+=("Worktree ($wt_path) に未コミット変更があるため保護")
    else
      CANDIDATE_BRANCHES+=("$branch")
      CANDIDATE_REASONS+=("$reason")
      CANDIDATE_WT_PATHS+=("$wt_path")
    fi
  fi
done <<< "$ALL_LOCAL_BRANCHES"

# 3. リモートブランチの判定 (オプション有効時)
CANDIDATE_REMOTE_BRANCHES=()
CANDIDATE_REMOTE_REASONS=()

if [[ "$INCLUDE_REMOTE" == true ]] && git remote | grep -q "^origin$"; then
  REMOTE_MERGED_RAW="$(git branch -r --merged "origin/$DEFAULT_BRANCH" 2>/dev/null | sed 's/^[ *]*//' || true)"
  while IFS= read -r rbranch; do
    [[ -z "$rbranch" ]] && continue
    if [[ "$rbranch" =~ ^origin/HEAD ]] || [[ "$rbranch" =~ ^origin/$DEFAULT_BRANCH$ ]]; then
      continue
    fi
    short_name="${rbranch#origin/}"
    if is_protected_branch "$short_name"; then
      continue
    fi
    CANDIDATE_REMOTE_BRANCHES+=("$short_name")
    CANDIDATE_REMOTE_REASONS+=("merged (into origin/$DEFAULT_BRANCH)")
  done <<< "$REMOTE_MERGED_RAW"
fi

# ==============================================================================
# 出力処理
# ==============================================================================

if [[ "$OUTPUT_JSON" == true ]]; then
  json_local="["
  if [[ ${#CANDIDATE_BRANCHES[@]} -gt 0 ]]; then
    for i in "${!CANDIDATE_BRANCHES[@]}"; do
      [[ $i -gt 0 ]] && json_local+=","
      json_local+="{\"branch\":\"${CANDIDATE_BRANCHES[$i]}\",\"reason\":\"${CANDIDATE_REASONS[$i]}\",\"worktree\":\"${CANDIDATE_WT_PATHS[$i]}\"}"
    done
  fi
  json_local+="]"

  json_skipped="["
  if [[ ${#SKIPPED_BRANCHES[@]} -gt 0 ]]; then
    for i in "${!SKIPPED_BRANCHES[@]}"; do
      [[ $i -gt 0 ]] && json_skipped+=","
      json_skipped+="{\"branch\":\"${SKIPPED_BRANCHES[$i]}\",\"reason\":\"${SKIPPED_REASONS[$i]}\"}"
    done
  fi
  json_skipped+="]"

  json_remote="["
  if [[ ${#CANDIDATE_REMOTE_BRANCHES[@]} -gt 0 ]]; then
    for i in "${!CANDIDATE_REMOTE_BRANCHES[@]}"; do
      [[ $i -gt 0 ]] && json_remote+=","
      json_remote+="{\"branch\":\"${CANDIDATE_REMOTE_BRANCHES[$i]}\",\"reason\":\"${CANDIDATE_REMOTE_REASONS[$i]}\"}"
    done
  fi
  json_remote+="]"

  cat << EOF
{
  "mode": "$MODE",
  "default_branch": "$DEFAULT_BRANCH",
  "current_branch": "$CURRENT_BRANCH",
  "candidates": {
    "local_branches": $json_local,
    "remote_branches": $json_remote
  },
  "skipped": $json_skipped
}
EOF
  exit 0
fi

MODE_UPPER="$(echo "$MODE" | tr '[:lower:]' '[:upper:]')"
echo -e "${COLOR_BOLD}=== Git Cleanup (${MODE_UPPER}) ===${COLOR_RESET}"
echo -e "リポジトリ: ${COLOR_CYAN}$GIT_ROOT${COLOR_RESET}"
echo -e "デフォルトブランチ: ${COLOR_GREEN}$DEFAULT_BRANCH${COLOR_RESET} / 現在のブランチ: ${COLOR_YELLOW}$CURRENT_BRANCH${COLOR_RESET}"
echo ""

if [[ ${#SKIPPED_BRANCHES[@]} -gt 0 ]]; then
  echo -e "${COLOR_YELLOW}${COLOR_BOLD}⚠️  スキップ対象 (未コミット変更等により保護):${COLOR_RESET}"
  for i in "${!SKIPPED_BRANCHES[@]}"; do
    echo -e "  - ${COLOR_YELLOW}${SKIPPED_BRANCHES[$i]}${COLOR_RESET} : ${SKIPPED_REASONS[$i]}"
  done
  echo ""
fi

TOTAL_CANDIDATES=$(( ${#CANDIDATE_BRANCHES[@]} + ${#CANDIDATE_REMOTE_BRANCHES[@]} ))

if [[ $TOTAL_CANDIDATES -eq 0 ]]; then
  echo -e "${COLOR_GREEN}✨ 削除対象のブランチや Worktree は見つかりませんでした。リポジトリはクリーンです。${COLOR_RESET}"
  exit 0
fi

echo -e "${COLOR_BOLD}📋 削除対象リスト:${COLOR_RESET}"

if [[ ${#CANDIDATE_BRANCHES[@]} -gt 0 ]]; then
  echo -e "${COLOR_CYAN}■ ローカルブランチ / Worktree (${#CANDIDATE_BRANCHES[@]} 件):${COLOR_RESET}"
  for i in "${!CANDIDATE_BRANCHES[@]}"; do
    b="${CANDIDATE_BRANCHES[$i]}"
    r="${CANDIDATE_REASONS[$i]}"
    wt="${CANDIDATE_WT_PATHS[$i]}"
    wt_str=""
    if [[ -n "$wt" ]]; then
      wt_str=" ${COLOR_BLUE}[Worktree: $wt]${COLOR_RESET}"
    fi
    echo -e "  ${COLOR_RED}✗${COLOR_RESET} ${COLOR_BOLD}$b${COLOR_RESET} ${COLOR_GRAY}($r)${COLOR_RESET}$wt_str"
  done
  echo ""
fi

if [[ ${#CANDIDATE_REMOTE_BRANCHES[@]} -gt 0 ]]; then
  echo -e "${COLOR_CYAN}■ リモートブランチ (origin) (${#CANDIDATE_REMOTE_BRANCHES[@]} 件):${COLOR_RESET}"
  for i in "${!CANDIDATE_REMOTE_BRANCHES[@]}"; do
    rb="${CANDIDATE_REMOTE_BRANCHES[$i]}"
    rr="${CANDIDATE_REMOTE_REASONS[$i]}"
    echo -e "  ${COLOR_RED}✗${COLOR_RESET} ${COLOR_BOLD}origin/$rb${COLOR_RESET} ${COLOR_GRAY}($rr)${COLOR_RESET}"
  done
  echo ""
fi

if [[ "$MODE" != "execute" ]]; then
  echo -e "${COLOR_YELLOW}※ 現在は Dry-Run モードです。実際の削除は行われていません。${COLOR_RESET}"
  echo -e "削除を実行するには: ${COLOR_BOLD}$0 --execute${COLOR_RESET}"
  if [[ "$INCLUDE_REMOTE" == true ]]; then
    echo -e "ローカルのみを対象にする場合: ${COLOR_BOLD}$0 --local-only --execute${COLOR_RESET}"
  fi
  exit 0
fi

# ==============================================================================
# 実行 (削除) 処理
# ==============================================================================
echo -e "${COLOR_BOLD}${COLOR_RED}🗑️  削除処理を実行中...${COLOR_RESET}"
echo ""

# 1. Worktree の削除
if [[ ${#CANDIDATE_BRANCHES[@]} -gt 0 ]]; then
  for i in "${!CANDIDATE_BRANCHES[@]}"; do
    wt="${CANDIDATE_WT_PATHS[$i]}"
    if [[ -n "$wt" ]]; then
      echo -e "  - Worktree を削除中: ${COLOR_CYAN}$wt${COLOR_RESET}"
      if git worktree remove "$wt" 2>/dev/null; then
        echo -e "    ${COLOR_GREEN}✓ Worktree を削除しました${COLOR_RESET}"
      else
        echo -e "    ${COLOR_YELLOW}⚠️  Worktree remove 失敗。force 実行します${COLOR_RESET}"
        git worktree remove --force "$wt" || echo -e "    ${COLOR_RED}✗ Worktree 削除に失敗しました${COLOR_RESET}"
      fi
    fi
  done
fi

git worktree prune >/dev/null 2>&1 || true

# 2. ローカルブランチの削除
if [[ ${#CANDIDATE_BRANCHES[@]} -gt 0 ]]; then
  for i in "${!CANDIDATE_BRANCHES[@]}"; do
    b="${CANDIDATE_BRANCHES[$i]}"
    echo -e "  - ローカルブランチを削除中: ${COLOR_CYAN}$b${COLOR_RESET}"
    if git branch -d "$b" 2>/dev/null; then
      echo -e "    ${COLOR_GREEN}✓ 削除完了 (git branch -d)${COLOR_RESET}"
    else
      if git branch -D "$b" 2>/dev/null; then
        echo -e "    ${COLOR_GREEN}✓ 削除完了 (git branch -D)${COLOR_RESET}"
      else
        echo -e "    ${COLOR_RED}✗ ブランチ削除に失敗しました: $b${COLOR_RESET}"
      fi
    fi
  done
fi

# 3. リモートブランチの削除
if [[ ${#CANDIDATE_REMOTE_BRANCHES[@]} -gt 0 ]]; then
  for i in "${!CANDIDATE_REMOTE_BRANCHES[@]}"; do
    rb="${CANDIDATE_REMOTE_BRANCHES[$i]}"
    echo -e "  - リモートブランチを削除中: ${COLOR_CYAN}origin/$rb${COLOR_RESET}"
    if git push origin --delete "$rb" 2>/dev/null; then
      echo -e "    ${COLOR_GREEN}✓ リモートブランチ削除完了${COLOR_RESET}"
    else
      echo -e "    ${COLOR_RED}✗ リモートブランチ削除に失敗しました: origin/$rb${COLOR_RESET}"
    fi
  done
fi

echo ""
echo -e "${COLOR_GREEN}${COLOR_BOLD}🎉 クリーンアップが完了しました！${COLOR_RESET}"
