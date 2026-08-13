# Issue First 開発規約 (Issue-Driven Development Rule)

コードの実装や設定の変更を行う前に、必ず GitHub Issue を作成（または確認）して作業をトラックしてください。

## 適用対象
- 機能追加、バグ修正、リファクタリング、設定作成など、コード変更を伴うすべての実装タスク。
- ※ 調査・質問への回答・簡単なログ確認などの非破壊的タスクは除きます。

## 必須ワークフロー

### 1. 実装前の Issue 作成
1. **タスクの整理**: 実装を開始する前に、Issue のタイトル、背景、具体的な対応作業（ToDoリスト）を整理します。
2. **Issue の自動作成**: GitHub CLI (`gh issue create`) を実行して Issue を起票し、Issue 番号（`#N`）を取得します。

### 2. 作業ブランチの作成
- **ブランチ名の命名規則**: `<PRの種別>/<issue番号>-<変更内容>`
  - 種別の例: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
  - 例: `feat/16-add-user-login`
  - 例: `docs/15-add-agent-rules`
  - 例: `fix/18-resolve-build-error`

### 3. コミットおよび PR への紐付け
- **コミットメッセージ**: メッセージに Issue 番号を含めます（例: `feat: #16 〇〇機能の追加`）。
- **Pull Request**: PR の説明文に `Closes #16` を含め、PR マージ時に自動的に Issue がクローズされるようにします。
