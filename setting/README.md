# 設定

- [始め方](#始め方)
  - [前提](#前提)
  - [インストール](#インストール)
- [使い方](#使い方)
  - [スクリプト実行](#スクリプト実行)
  - [パッケージ関連](#パッケージ関連)
    - [インストール](#インストール)
    - [パッケージの更新](#パッケージの更新)
    - [パッケージの追加](#パッケージの追加)
    - [パッケージの削除](#パッケージの削除)
    - [特別対応](#特別対応)
  - [AIエージェントスキル関連](#aiエージェントスキル関連)
    - [スキルのインストール](#スキルのインストール)
    - [スキルの追加](#スキルの追加)
    - [スキルの更新](#スキルの更新)
  - [Antigravity IDE関連](#antigravity-ide関連)
  - [Mac関連](#mac関連)

## 始め方

### 前提

- Git
- Homebrew

### インストール

1. リポジトリをclone

   ```sh
   git clone git@github.com:anineko280/lab.git
   ```

1. リポジトリのディレクトリに移動

   ```sh
   cd lab
   ```

### GitHubの設定

[Settings] - [Emails] - [Keep my email addresses private] を`On`にすること。
自分のメールアドレスがコミットに記録されないようにするため。
また、払い出されたメールアドレスは [setting/dotfiles/gitconfig] の`email`に設定すること

## 使い方

### スクリプト実行

```sh
./setup.sh
```

### パッケージ関連

#### パッケージのインストール

```sh
brew bundle
```

#### パッケージの更新

```sh
brew upgrade
```

#### パッケージの追加

```sh
brew install hoge
brew bundle dump -f
```

#### パッケージの削除

```sh
brew uninstall hoge
brew bundle dump -f
```

#### 特別対応

- awscli
  - Homebrewでインストールしようとすると大量の依存パッケージが入ってしまうため、公式インストーラーを使ってください
- gh (GitHub CLI)
  - ログイン認証: `gh auth login`（対話形式で `GitHub.com` / `HTTPS` or `SSH` / Webブラウザ認証を選択して承認）
  - 状態確認: `gh auth status`

### AIエージェントスキル関連

`gh skill` コマンドを活用し、各AIエージェント（Antigravity, Claude Code, GitHub Copilot）用のスキルをグローバル環境（user scope）に一括インストール・管理します。

#### スキルのインストール

`setup_skills.sh` を実行（または `./setup.sh` 実行時にも自動的に呼び出されます）。

```sh
./setup_skills.sh
```

#### スキルの追加

1. `setting/agent/skills.json` の `skills` リストに対象のリポジトリとスキル名を追記します（エージェントを追加したい場合は `agents` リストにも追記）。

```json
{
  "agents": [
    "antigravity",
    "claude-code",
    "github-copilot"
  ],
  "skills": [
    {
      "repo": "anthropics/skills",
      "skill": "skill-creator"
    },
    {
      "repo": "owner/repo",
      "skill": "skill-name"
    }
  ]
}
```

2. `./setup_skills.sh` を再実行してインストールを反映します。

#### スキルの更新

```sh
# 全スキルの最新化
gh skill update --all
```

### Antigravity IDE関連

- Antigravity IDEのプロファイル機能を使う
- `agy-ide/*.code-profile`からシチュエーションにあったプロファイルを使う
  - インポート、エクスポート方法はAntigravity IDEのバージョンによって異なるので適切な方法でやる

### Mac関連

defaults コマンドでもできるだろうけど plist の変更に追従するのがしんどそうなので手動でやる。

- [ ] [¥]を叩いた時に[\\]が入力されるようにする
- [ ] キーのリピート速度 最速
- [ ] リピートの認識 短め
- [ ] タップでクリック
- [ ] カーソル右下でスクリーンセーバを無効化
- [ ] トラックパッドの軌跡の速さ 気持ち速め
- [ ] Dock を自動的に表示、非表示
- [ ] Dock を左に表示
- [ ] Finder の設定の更新
- [ ] ctl + スクロールでズームできるようにする

### その他

#### GitHub

- 全体
  - [ ] SSHで接続できるようにする
- リポジトリごと
  - [ ] コミットにメールアドレスが記録されないようにする
  - [ ] issueテンプレート、PRテンプレートを用意する
  - [ ] ブランチプロテクションを設定する
  - [ ] 自分以外がコミットできないようにする
