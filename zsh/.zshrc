# # completion
# autoload -U compinit
# compinit

# aliases
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -a --color=auto'
alias lla='ls -la --color=auto'
alias grep='grep --color=auto'

# # prompt
# PROMPT='%F{036}%B%n@%m%b%f:%F{038}%~%f$ '
# #RPROMPT='[%F{green}%d%f]'
# 
# # history
# HISTFILE=~/.zsh_history
# HISTSIZE=65536
# SAVEHIST=65536
# setopt hist_ignore_dups
# autoload history-search-end
# #zle -N history-beginning-search-backword-end history-search-end

# ssh completion
function _ssh {
  compadd `grep 'Host ' ~/.ssh/config --color=none | awk '{print $2}' | sort`;
}

function _ssh_hosts {
  compadd `grep 'Host ' ~/.ssh/config --color=none | awk '{print $2}' | sort`;
}

# sdkman!
export SDKMAN_DIR="/home/keita/.sdkman"
[[ -s "/home/keita/.sdkman/bin/sdkman-init.sh" ]] && source "/home/keita/.sdkman/bin/sdkman-init.sh"

# zplug
source ~/.zplug/init.zsh

zplug "sorin-ionescu/prezto"
zplug "felixr/docker-zsh-completion", ignore:"docker-zsh-completion.plugin.zsh"
zplug "nobeans/zsh-sdkman"

zplug load # --verbose

# apply PATH to binaries that installed in local
. "$HOME/.local/bin/env"


# mise
eval "$(~/.local/bin/mise activate zsh)"

# rust toolchain
. "$HOME/.cargo/env"

# haskell
[ -f "/home/keis/.ghcup/env" ] && . "/home/keis/.ghcup/env" # ghcup-env

# neovim
alias vim=nvim
export PATH="/opt/nvim-linux-x86_64/bin:$PATH"

# git
export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes'

# android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/emulator:$PATH

# zprof
# if (which zprof > /dev/null) ;then
#   zprof | less
# fi
