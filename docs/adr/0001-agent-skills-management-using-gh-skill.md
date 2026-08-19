# 1. gh skill を用いたエージェントスキルの一元管理と自動セットアップ

- **ステータス**: Accepted
- **日付**: 2026-08-19
- **対象**: `setting/agent/`, `setting/setup_skills.sh`

---

## 1. コンテキスト (Context)

AI コーディングエージェント（Antigravity, Claude Code, GitHub Copilot 等）を活用するにあたり、共通で利用したいエージェントスキル（Agent Skills）をローカルマシン環境で一元管理する必要があった。

初期検討として、他の dotfiles 同様に `setting/skills/` にスキルの実体を置き、`~/.gemini/config/skills` や各エージェントの設定ディレクトリへシンボリックリンクを貼る方式も検討されたが、以下の課題があった：
- エージェントごとにスキルの配置ディレクトリ階層が異なる（`~/.gemini/antigravity/skills`, `~/.claude/skills`, `~/.copilot/skills` 等）。
- シンボリックリンクでは上流リポジトリの更新追従やメタデータ管理が手動となり煩雑になる。

---

## 2. 決定事項 (Decision)

1. **管理方式**:
   - シンボリックリンクではなく、GitHub 公式の **`gh skill`** コマンドを活用する。
   - グローバル環境（`user` スコープ）に対してスキルを配布・インストールする。
2. **設定とスクリプトの分離**:
   - 対象エージェントおよび管理対象スキルの一覧は **`setting/agent/skills.json`** に定義する。
   - スクリプト側（`setting/setup_skills.sh`）はロジックのみとし、**`jq`** を用いて `skills.json` を動的にパースしてループ処理を行う。
3. **セットアップ連携**:
   - マシンの初期セットアップスクリプト `setting/setup.sh` から `setup_skills.sh` を自動呼び出しし、環境構築時に自動でスキルが展開される構成とする。

---

## 3. 結果・影響 (Consequences)

### メリット
- **複数エージェントへの統一配布**: 1つの JSON ファイルに定義を追加するだけで、サポートする全エージェントへ一括でスキルをインストールできる。
- **公式機能との親和性**: `gh skill` のバージョン管理、メタデータ付与、`gh skill update --all` による一括更新機能を活用できる。
- **保守性の向上**: スクリプト本体を修正することなく、JSON の編集のみでスキルの追加・削除が可能。

### 制約・留意点
- セットアップ実行環境に `gh` (GitHub CLI) および `jq` が必要（`setting/dotfiles/Brewfile` に含めることで担保）。
