# # completion
# autoload -U compinit
# compinit

# set color
export TERM="xterm-256color"

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

# sdkman!
export SDKMAN_DIR="/home/keita/.sdkman"
[[ -s "/home/keita/.sdkman/bin/sdkman-init.sh" ]] && source "/home/keita/.sdkman/bin/sdkman-init.sh"

# zplug
source ~/.zplug/init.zsh

zplug "sorin-ionescu/prezto"
zplug "felixr/docker-zsh-completion", ignore:"docker-zsh-completion.plugin.zsh"
zplug "nobeans/zsh-sdkman"

zplug load # --verbose

# zprof
# if (which zprof > /dev/null) ;then
#   zprof | less
# fi

