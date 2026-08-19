---
description: labリポジトリにおけるmiseランタイム管理とプロジェクト運用の規約
---

# Workspace Rules & Conventions (lab)

## 1. ランタイム管理 (mise)
- ランタイム・言語バージョン（Node.js, Python, Go 等）の管理には **`mise`** を使用します。
- **グローバル環境へのインストール・変更は禁止**:
  - `mise use --global` や `~/.config/mise/config.toml` の直接編集は行いません。
- **プロジェクトローカル管理の徹底**:
  - 各プロジェクト（`profile/`, `learning/<topic>/` など）のディレクトリ直下に `.mise.toml` を作成してバージョンを固定します。
  - 例: `profile/.mise.toml`
    ```toml
    [tools]
    node = "lts"
    ```

## 2. ディレクトリ構造と責務
- `setting/`: Mac初期セットアップスクリプト (`setup.sh`)、dotfiles (`zshrc`, `gitconfig`)、Homebrew (`Brewfile`) の管理。
- `learning/`: 新技術の検証・学習用プロトタイプ。
- `profile/`: プロフィールサイト（Vite + React + TypeScript）。
- 新しい検証やアプリを追加する際は、各ディレクトリの独立性を保ち、必要な設定をプロジェクト内に閉じ込めます。

## 3. ドキュメンテーションと図解（Mermaid）規約
- **解説・コードツアーの配置**:
  - プロジェクトの全体構造やコード解説・Q&Aを記録するドキュメントは、一時アーティファクトと区別するため、各プロジェクトの `docs/TOUR.md`（または `docs/` 配下）に永続化します。
- **図解・Mermaid の使い分け**:
  - **チャットでの回答時**: プレビューが効かないため、生の Mermaid コードブロックは出力せず、視認性の高いテキスト/ASCII図を使用します。
  - **Markdown ドキュメント（`docs/` 配下等）**: エディタの Markdown プレビューでリッチに可視化できるよう、Mermaid 記法（シーケンス図、フローチャート等）で構造化して記述します。

