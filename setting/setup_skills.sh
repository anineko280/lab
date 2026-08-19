#!/bin/zsh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/agent/skills.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "エラー: 設定ファイル '$CONFIG_FILE' が見つかりません。" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "エラー: skills.json のパースに必要な 'jq' が見つかりません。brew 等でインストールしてください。" >&2
  exit 1
fi

# zsh のパラメータ展開フラグ (@f) を使用し、jq の改行区切り出力を配列に分割格納
AGENTS=("${(@f)$(jq -r '.agents[]' "$CONFIG_FILE")}")
SKILL_ENTRIES=("${(@f)$(jq -r '.skills[] | "\(.repo) \(.skill)"' "$CONFIG_FILE")}")

echo "=== AIエージェントスキルのインストール・更新を開始します ==="

# 各エージェントに対して指定されたスキルを user scope（グローバル）でインストール
for skill_entry in "${SKILL_ENTRIES[@]}"; do
  [ -z "$skill_entry" ] && continue
  repo=$(echo "$skill_entry" | awk '{print $1}')
  skill=$(echo "$skill_entry" | awk '{print $2}')

  for agent in "${AGENTS[@]}"; do
    [ -z "$agent" ] && continue
    echo "エージェント '${agent}' (user scope) に '${repo}' のスキル '${skill}' をインストール中..."
    if [ "$agent" = "antigravity" ]; then
      mkdir -p "$HOME/.gemini/config/skills"
      gh skill install "$repo" "$skill" --dir "$HOME/.gemini/config/skills" --force
    else
      gh skill install "$repo" "$skill" --agent "$agent" --scope user --force
    fi
  done
done

echo "=== AIエージェントスキルのセットアップが正常に完了しました ==="
