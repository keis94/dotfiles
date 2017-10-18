# Created by newuser for 5.1.1

# completion
autoload -U compinit
compinit

# aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# prompt
PROMPT='%F{036}%B%n@%m%b%f:%F{038}%~%f# '
#RPROMPT='[%F{green}%d%f]'

# history
HISTFILE=~/.zsh_history
HISTSIZE=65536
SAVEHIST=65536
setopt hist_ignore_dups
autoload history-search-end
#zle -N history-beginning-search-backword-end history-search-end

# ssh completion
function _ssh {
  compadd `grep 'Host ' ~/.ssh/config --color=none | awk '{print $2}' | sort`;
}
