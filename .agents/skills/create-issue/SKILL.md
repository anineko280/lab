---
name: create-issue
description: >-
  ユーザーの指示に基づいて GitHub Issue を起票し、規約に従った作業ブランチの作成までを案内・実行します。
  「Issueを作成して」「タスクを起票して」「バグ報告を作成して」などの要望で使用します。
---

# GitHub Issue 作成スキル (Issue Creation Workflow)

このスキルは、プロジェクトの Issue 規約 (`.agents/rules/issue.md`) および Git 規約 (`.agents/rules/git.md`) に沿って GitHub Issue を起票し、開発作業をスムーズに開始するための標準ワークフローを提供します。

---

## ワークフロー手順

### 1. タスク情報の整理と確認
ユーザーの依頼内容から以下の要素を整理します。情報が不足している場合は、ユーザーに確認または提案を行います。

1. **種別 (Type)**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore` のいずれか
2. **タイトル (Title)**: 変更概要を表す簡潔なタイトル（日本語）
3. **背景・目的 (Context)**: なぜこの作業が必要か、何を取り組むか
4. **作業内容 (ToDo)**: 具体的な対応内容のチェックリスト

### 2. Issue の作成 (`gh issue create`)
整理した内容を基に `gh issue create` コマンドを実行して GitHub 上に起票し、同時に GitHub Project（「いろいろ」）へ追加します。

```bash
gh issue create --project "いろいろ" --title "<種別>: <タイトル>" --body "$(cat <<'EOF'
## 概要・背景
<背景・目的>

## 対応作業 (ToDo)
- [ ] <作業項目1>
- [ ] <作業項目2>
EOF
)"
```

*実行後、発行された Issue 番号（例: `#12`）、Issue URL、およびプロジェクト追加結果を取得します。*

### 3. 作業ブランチの作成
起票した Issue 番号に基づいて、規約に従ったブランチ名で作業ブランチを作成・チェックアウトします。

- **ブランチ名規約**: `<種別>/<Issue番号>-<簡潔な英数ハイフン文字列>`
  - 例: Issue #12 の「ログイン機能の追加」 -> `feat/12-add-login`
  - 例: Issue #15 の「Issueルールの修正」 -> `docs/15-fix-issue-rule`

```bash
git checkout -b <ブランチ名>
```

### 4. ユーザーへの報告
起票完了後、以下の情報をユーザーに報告します。

- 作成された Issue の URL と番号 (`#N`)
- 作成および切替を行った作業ブランチ名
- 今後のコミット規約 (`<種別>: #<Issue番号> <コミットメッセージ>`) および PR での `Closes #<Issue番号>` の使用案内
