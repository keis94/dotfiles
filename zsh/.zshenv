# zprof
# zmodload zsh/zprof && zprof

# My setting
export ZDOTDIR=$HOME/.dotfiles/zsh/
export LANG='en_US.UTF-8'
export LC_TIME='en_US.UTF-8'

# prezto
# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

