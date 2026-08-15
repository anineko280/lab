# lab

個人の技術検証、ナレッジ蓄積、Mac環境設定、プロフィールサイトのソースコードなどを一元管理するモノリポジトリです。

---

## 📁 ディレクトリ構成

| ディレクトリ / ファイル | 説明 |
| :--- | :--- |
| [**`setting/`**](setting/) | Macの初期セットアップスクリプト (`setup.sh`)、Homebrew (`Brewfile`)、dotfiles (`zshrc`, `gitconfig` 等)、IDEプロファイルなどの管理 |
| [**`learning/`**](learning/) | 新技術の検証・学習用プロトタイプ（Vite, Docker Compose 等のハンズオン） |
| [**`profile/`**](profile/) | エンジニアプロフィール & ポートフォリオサイト（Vite + React + TypeScript + Glassmorphism Bento Grid） |

---

## 🚀 クイックスタート & 使い方

### 1. リポジトリの取得

```sh
git clone git@github.com:anineko280/lab.git
cd lab
```

### 2. Macの環境構築

Macの新環境セットアップやパッケージ管理を行う場合は `setting/` ディレクトリを参照してください。

```sh
cd setting
./setup.sh
```

詳細な設定項目や使い方は [setting/README.md](setting/README.md) をご確認ください。

### 3. 技術検証 (learning)

各種フレームワークやツールの検証コードは `learning/` 配下に格納されています。

- `learning/vite/` : Vite を用いたフロントエンド検証環境

### 4. プロフィールサイト (profile)

ダークグラスモーフィズムとBento Gridを採用したエンジニアプロフィールサイトです。

```sh
cd profile
mise install # Node.jsのセットアップ
npm install
npm run dev
```

ブラウザで `http://localhost:5173` にアクセスしてプレビューできます。プロフィール情報（名前・リンク・スキル等）の変更は [`profile/src/data/profile.ts`](profile/src/data/profile.ts) を編集します。

---

## 📝 開発方針・メモ

- 新しい技術検証を行う場合は `learning/<tool-or-topic>` 配下にディレクトリを作成して進めます。
- 設定ファイルやドキュメントは変更時に適宜更新します。
