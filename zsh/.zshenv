# Skip system compinit in /etc/zsh/zshrc (Ubuntu)
skip_global_compinit=1

# ZDOTDIR - where zsh looks for config files
export ZDOTDIR=$HOME/repo/dotfiles/zsh

# Enable zsh profiling
RUN_ZPROF=${RUN_ZPROF:-false}

if [ "$RUN_ZPROF" = true ]; then
    zmodload zsh/zprof && zprof
fi

# Locale
export LANG='en_US.utf8'

# XDG Base Directory
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
