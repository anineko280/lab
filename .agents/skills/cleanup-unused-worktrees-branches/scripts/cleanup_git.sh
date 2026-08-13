#!/usr/bin/env bash
set -euo pipefail

# Helper script for cleaning up unused Git worktrees and merged/gone branches safely.
# Usage:
#   bash cleanup_git.sh [--dry-run | --apply] [--target-branch MAIN_BRANCH]

DRY_RUN=true
MAIN_BRANCH="main"

while [[ $# -gt 0 ]]; do
  case $1 in
    --apply)
      DRY_RUN=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --target-branch)
      MAIN_BRANCH="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Ensure we are inside a Git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: Not a git repository."
  exit 1
fi

# Detect default branch if main doesn't exist
if ! git rev-parse --verify "$MAIN_BRANCH" >/dev/null 2>&1; then
  if git rev-parse --verify master >/dev/null 2>&1; then
    MAIN_BRANCH="master"
  fi
fi

echo "=== Git Cleanup Inspector ==="
echo "Target Base Branch: $MAIN_BRANCH"
echo "Mode: $(if $DRY_RUN; then echo 'DRY-RUN (Inspection only)'; else echo 'APPLY (Deleting targets)'; fi)"
echo ""

# 1. Inspect Worktrees
echo "--- [1/2] Worktrees Inspection ---"
CURRENT_WORKTREE=$(git rev-parse --show-toplevel 2>/dev/null || true)
WORKTREE_PATHS=()

# Parse porcelain worktree list
while IFS= read -r line; do
  if [[ "$line" =~ ^worktree\ (.*) ]]; then
    WORKTREE_PATHS+=("${BASH_REMATCH[1]}")
  fi
done < <(git worktree list --porcelain)

SAFE_TO_REMOVE_WORKTREES=()

for wt in "${WORKTREE_PATHS[@]}"; do
  # Skip if current worktree
  if [[ "$wt" == "$CURRENT_WORKTREE" ]]; then
    echo "  [SKIP] Current active worktree: $wt"
    continue
  fi

  # Check if directory exists
  if [[ ! -d "$wt" ]]; then
    echo "  [STALE] Directory missing (prunable): $wt"
    SAFE_TO_REMOVE_WORKTREES+=("$wt")
    continue
  fi

  # Check git status inside worktree
  UNCOMMITTED=$(git -C "$wt" status --porcelain 2>/dev/null || true)
  BRANCH_NAME=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || true)

  if [[ "$BRANCH_NAME" == "$MAIN_BRANCH" || "$BRANCH_NAME" == "master" || "$BRANCH_NAME" == "develop" ]]; then
    echo "  [SKIP] Main branch worktree ($BRANCH_NAME): $wt"
    continue
  fi

  if [[ -n "$UNCOMMITTED" ]]; then
    echo "  [WARNING] Worktree has uncommitted changes: $wt (Branch: $BRANCH_NAME)"
  else
    echo "  [TARGET] Clean worktree ready for removal: $wt (Branch: $BRANCH_NAME)"
    SAFE_TO_REMOVE_WORKTREES+=("$wt")
  fi
done

echo ""

# 2. Inspect Branches
echo "--- [2/2] Branches Inspection ---"
MERGED_BRANCHES=()
GONE_BRANCHES=()

# Merged branches
while IFS= read -r b; do
  b_clean=$(echo "$b" | sed 's/^[*+ ]*//')
  if [[ "$b_clean" != "$MAIN_BRANCH" && "$b_clean" != "master" && "$b_clean" != "develop" && "$b_clean" != "HEAD"* ]]; then
    MERGED_BRANCHES+=("$b_clean")
  fi
done < <(git branch --merged "$MAIN_BRANCH" 2>/dev/null || true)

# Gone tracking branches
while IFS= read -r line; do
  b_name=$(echo "$line" | awk '{print $1}' | sed 's/^[*+ ]*//')
  if [[ "$b_name" != "$MAIN_BRANCH" && "$b_name" != "master" && "$b_name" != "develop" ]]; then
    GONE_BRANCHES+=("$b_name")
  fi
done < <(git branch -vv 2>/dev/null | grep ': gone]' || true)

# Combine unique branches
ALL_TARGET_BRANCHES=()
if [[ ${#MERGED_BRANCHES[@]} -gt 0 || ${#GONE_BRANCHES[@]} -gt 0 ]]; then
  ALL_TARGET_BRANCHES=($(echo "${MERGED_BRANCHES[@]:-} ${GONE_BRANCHES[@]:-}" | tr ' ' '\n' | sort -u | grep -v '^$' || true))
fi

# Filter out branches that are currently checked out in active worktrees
SAFE_TO_DELETE_BRANCHES=()
if [[ ${#ALL_TARGET_BRANCHES[@]} -gt 0 ]]; then
  for b in "${ALL_TARGET_BRANCHES[@]}"; do
    IS_CHECKED_OUT=false
    for wt in "${WORKTREE_PATHS[@]}"; do
      wt_b=$(git -C "$wt" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
      if [[ "$wt_b" == "$b" ]]; then
        IS_CHECKED_OUT=true
        break
      fi
    done

    if $IS_CHECKED_OUT; then
      echo "  [SKIP] Branch currently checked out in worktree: $b"
    else
      echo "  [TARGET] Branch ready for deletion: $b"
      SAFE_TO_DELETE_BRANCHES+=("$b")
    fi
  done
fi

echo ""
echo "=== Summary ==="
echo "Worktrees to remove (${#SAFE_TO_REMOVE_WORKTREES[@]}):"
if [[ ${#SAFE_TO_REMOVE_WORKTREES[@]} -gt 0 ]]; then
  for wt in "${SAFE_TO_REMOVE_WORKTREES[@]}"; do
    echo "  - $wt"
  done
fi

echo "Branches to delete (${#SAFE_TO_DELETE_BRANCHES[@]}):"
if [[ ${#SAFE_TO_DELETE_BRANCHES[@]} -gt 0 ]]; then
  for b in "${SAFE_TO_DELETE_BRANCHES[@]}"; do
    echo "  - $b"
  done
fi
echo ""

if $DRY_RUN; then
  echo "Dry-run complete. No changes were made."
  echo "To execute deletion, run with --apply flag."
  exit 0
fi

echo "=== Executing Deletion ==="

# Remove Worktrees
if [[ ${#SAFE_TO_REMOVE_WORKTREES[@]} -gt 0 ]]; then
  for wt in "${SAFE_TO_REMOVE_WORKTREES[@]}"; do
    echo "Removing worktree: $wt"
    git worktree remove "$wt" || git worktree remove --force "$wt" || echo "Failed to remove worktree: $wt"
  done
fi

# Prune Worktrees
echo "Pruning worktree metadata..."
git worktree prune

# Delete Branches
if [[ ${#SAFE_TO_DELETE_BRANCHES[@]} -gt 0 ]]; then
  for b in "${SAFE_TO_DELETE_BRANCHES[@]}"; do
    echo "Deleting branch: $b"
    git branch -d "$b" || git branch -D "$b" || echo "Failed to delete branch: $b"
  done
fi

echo "Pruning remote tracking branches..."
git remote prune origin 2>/dev/null || true

echo "=== Cleanup Completed Successfully ==="
