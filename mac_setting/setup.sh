#!/bin/zsh

ln -sf "$(pwd)/dotfiles/Brewfile" ~/.Brewfile # brew dumpの運用を楽にするためホームにリンクを作成
ln -sf "$(pwd)/dotfiles/vimrc" ~/.vimrc
ln -sf "$(pwd)/dotfiles/zshrc" ~/.zshrc
ln -sf "$(pwd)/dotfiles/gitconfig" ~/.gitconfig
