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
