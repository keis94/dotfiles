#!/bin/sh

set -eu

for file in .??*; do
  if [ "$file" != ".git" ] && [ "$file" != ".gitignore" ]; then
    ln -s $HOME/.dotfiles/$file $HOME/$file
  fi
done
ln -s $HOME/.dotfiles/zsh/.zshenv $HOME/.zshenv

# Install zplug + prezto
export ZPLUG_HOME=$HOME/.zplug
git clone https://github.com/zplug/zplug $ZPLUG_HOME
ln -s $HOME/.zplug/repos/sorin-ionescu/prezto $HOME/.zprezto

# Setting for nvim + dein
mkdir ~/.config
ln -s $PWD/.vim $HOME/.config/nvim
ln -s $PWD/dein $HOME/.config/dein

