#!/bin/zsh

set -eu

for file in .??*; do
  if [ "$file" != ".git" ] && [ "$file" != ".gitignore" ]; then
    ln -s $HOME/.dotfiles/$file $HOME/$file
  fi
done
ln -s $HOME/.dotfiles/zsh/.zshenv $HOME/.zshenv

# Install zplug + prezto
export ZPLUG_HOME=$HOME/.dotfiles/zsh/.zplug
git clone https://github.com/zplug/zplug $ZPLUG_HOME
ln -s $HOME/.dotfiles/zsh/.zplug $HOME/.zplug
ln -s $HOME/.zplug/repos/sorin-ionescu/prezto $HOME/.zprezto

# Setting for nvim + dein
mkdir ~/.config
ln -s $PWD/nvim $HOME/.config/nvim
ln -s $PWD/dein $HOME/.config/dein

zsh -c 'source $ZDOTDIR/.zshrc; zplug install'
exec zsh -l
