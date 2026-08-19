#!/bin/zsh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

ln -sf "$SCRIPT_DIR/dotfiles/Brewfile" ~/.Brewfile # brew dumpの運用を楽にするためホームにリンクを作成
ln -sf "$SCRIPT_DIR/dotfiles/vimrc" ~/.vimrc
ln -sf "$SCRIPT_DIR/dotfiles/zshrc" ~/.zshrc
ln -sf "$SCRIPT_DIR/dotfiles/gitconfig" ~/.gitconfig

# Agent Skills セットアップ
if [ -f "$SCRIPT_DIR/setup_skills.sh" ]; then
  "$SCRIPT_DIR/setup_skills.sh"
fi
