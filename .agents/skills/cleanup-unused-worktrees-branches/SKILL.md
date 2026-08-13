---
name: cleanup-unused-worktrees-branches
description: >-
  Use this skill when the user asks to clean up, inspect, or delete unused Git worktrees and merged or stale local branches.
---

# Git Worktree & Branch Cleanup Skill

不要になった Git worktree およびマージ済み・削除済みのローカルブランチを安全に検査・整理するためのスキルです。

---

## 適用条件 (Trigger)

以下のようなユーザーリクエストを受けた場合にこのスキルを適用します：
- 「使っていない git worktree を削除したい」
- 「マージ済みのブランチを整理・削除したい」
- 「Git のクリーンアップを実行してディスク容量を空けたい」
- 「削除されたリモートブランチに対応するローカルブランチ (`[gone]`) を一括削除したい」

---

## 安全原則 (Safety Rules)

1. **未コミット変更の保護**: 未コミットの変更 (`git status --porcelain` で検出) が存在する worktree は、ユーザーの明示的な許可がない限り削除してはなりません。
2. **保護ブランチの除外**: `main`, `master`, `develop`, および現在のカレントワークツリーのブランチは絶対に削除対象に含めません。
3. **対話的確認の実施**: 実際に削除コマンドを実行する前に、削除対象となる worktree パスおよびブランチ一覧をユーザーに提示し、合意を得てから実行します。
4. **Dry-Run ファースト**: 最初に削除を実行せず、検査 (Dry-run) のみを行って対象を一覧化します。

---

## 実行フロー (Workflow)

### 手順 1: ヘルパースクリプトによる検査 (Dry-Run)

同梱されているヘルパースクリプト [cleanup_git.sh](./scripts/cleanup_git.sh) を Dry-run モードで実行し、削除対象を特定します。

```bash
bash .agents/skills/cleanup-unused-worktrees-branches/scripts/cleanup_git.sh --dry-run
```

※ ベースブランチが `main` 以外（例: `master` や `develop`）の場合は `--target-branch master` オプションを指定します。

### 手順 2: 検出結果の分析とユーザーへの提示

スクリプトの出力結果を元に、以下の項目をユーザーに明確に報告・確認します：

1. **削除対象の Worktree 一覧**:
   - パス
   - 対応するブランチ名
2. **削除対象のブランチ一覧**:
   - `main` にマージ済みのブランチ
   - リモート側で削除済みの追跡ブランチ (`[gone]`)
3. **スキップ・警告項目**:
   - 未コミットの変更があるためスキップされた worktree
   - 現在作業中のアクティブな worktree

### 手順 3: 削除の実行 (Execute)

ユーザーから承認を得たら、以下のいずれかの方法で削除を実行します。

#### 方法 A: ヘルパースクリプトによる一括削除
```bash
bash .agents/skills/cleanup-unused-worktrees-branches/scripts/cleanup_git.sh --apply
```

#### 方法 B: 個別コマンドによる手動削除
スクリプトを使わず手動で削除する場合は、以下の順序で安全に実行します：

1. **Worktree の削除**:
   ```bash
   git worktree remove <worktree-path>
   ```
2. **Worktree メタデータの整理**:
   ```bash
   git worktree prune
   ```
3. **マージ済みブランチの削除**:
   ```bash
   git branch -d <branch-name>
   ```
4. **リモート追跡ブランチの参照整理**:
   ```bash
   git remote prune origin
   ```

---

## 検証 (Verification)

削除完了後、以下のコマンドを実行して残りの worktree とブランチの状態が正常であることを確認します。

```bash
git worktree list
git branch -vv
```

クリーンアップ後の状態をユーザーに要約して報告します。
