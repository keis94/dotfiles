# zprof
# zmodload zsh/zprof && zprof

# My setting
export ZDOTDIR=$HOME/repo/dotfiles/zsh
export LANG='en_US.utf8'
export LC_TIME='en_US.utf8'

# prezto
# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share

