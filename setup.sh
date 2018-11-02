#!/bin/zsh

set -eu

ln -sin $HOME/.dotfiles/.tmux.conf $HOME/.tmux.conf
ln -sin $HOME/.dotfiles/zsh/.zshenv $HOME/.zshenv

# Install zplug + prezto
export ZPLUG_HOME=$HOME/.dotfiles/zsh/.zplug
[ ! -e $ZPLUG_HOME ] && git clone https://github.com/zplug/zplug $ZPLUG_HOME
ln -sin $ZPLUG_HOME $HOME/.zplug
ln -sin $ZPLUG_HOME/repos/sorin-ionescu/prezto $HOME/.zprezto

# Setting for nvim + dein
mkdir -p ~/.config
ln -sin $PWD/nvim $HOME/.config/nvim
ln -sin $PWD/dein $HOME/.config/dein

# Install anyenv & pyenv for neovim
if ! zsh -lc 'type anyenv' > /dev/null; then
  git clone https://github.com/riywo/anyenv.git $HOME/.anyenv
  zsh -lc 'git clone https://github.com/znz/anyenv-update.git $(anyenv root)/plugins/anyenv-update'
fi

if ! zsh -lc 'type "pyenv"' > /dev/null; then
  zsh -lc 'anyenv install pyenv'
fi

zsh -lc 'git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv;'
zsh -lc 'pyenv install 3.6.6 -s;\
         pyenv install 2.7.15 -s;\
         pyenv global 3.6.6;\
         pyenv virtualenv 3.6.6 neovim-python3;\
         pyenv virtualenv 2.7.15 neovim-python2;\
         pyenv activate neovim-python3;\
         pip install neovim;\
         pyenv deactivate;\
         pyenv activate neovim-python2;\
         pip install neovim'


zsh -c 'source $ZDOTDIR/.zshrc; zplug install'
exec zsh -li
