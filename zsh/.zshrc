# ==============================================================================
# Zsh Options (migrated from Prezto)
# ==============================================================================

eval "$(sheldon source)"

# History
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=65536
SAVEHIST=65536
setopt BANG_HIST              # Treat '!' specially during expansion
setopt EXTENDED_HISTORY       # Write timestamps to history
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first
setopt HIST_IGNORE_DUPS       # Ignore duplicates
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate
setopt HIST_FIND_NO_DUPS      # Don't display duplicates during search
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_SAVE_NO_DUPS      # Don't write duplicates
setopt HIST_VERIFY            # Don't execute immediately on history expansion

# Directory
setopt AUTO_CD                # cd without typing cd
setopt AUTO_PUSHD             # Push old directory onto stack
setopt PUSHD_IGNORE_DUPS      # Don't push duplicates
setopt PUSHD_SILENT           # Don't print stack after pushd/popd
setopt PUSHD_TO_HOME          # pushd without args goes to home
DIRSTACKSIZE=20

# Editor / Key bindings
bindkey -e                    # Emacs key bindings
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'  # Characters treated as part of a word

# ==============================================================================
# Completion
# ==============================================================================

# Completion options (based on Prezto)
setopt COMPLETE_IN_WORD       # Complete from cursor position
setopt ALWAYS_TO_END          # Move cursor to end after completion
setopt PATH_DIRS              # Perform path search for commands with slashes
setopt AUTO_PARAM_SLASH       # Add slash for directories
setopt EXTENDED_GLOB          # Needed for file modification glob modifiers with compinit
unsetopt BEEP                 # Keep silent
unsetopt MENU_COMPLETE        # Don't autoselect first completion
unsetopt FLOW_CONTROL         # Disable start/stop characters in shell editor

# Completion styles
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

# fzf-tab
zstyle ':fzf-tab:*' fzf-flags '--pointer=>' '--marker=+'

# pure prompt
zstyle ':prompt:pure:path' color '#005faf'

# ==============================================================================
# Aliases
# ==============================================================================

alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -a --color=auto'
alias lla='ls -la --color=auto'
alias grep='grep --color=auto'

# ==============================================================================
# Repository Navigation (ghq + fzf)
# ==============================================================================

function repo {
  local root="$(ghq root)"
  if [[ -n "$1" ]]; then
    cd "$root/$1"
  else
    local selected
    selected=$(ghq list | fzf)
    [[ -n "$selected" ]] && cd "$root/$selected"
  fi
}

function _repo {
  local -a repos
  repos=(${(f)"$(ghq list)"})
  _describe 'repository' repos
}

compdef _repo repo

# ==============================================================================
# SSH Completion
# ==============================================================================

function _ssh {
  compadd `grep 'Host ' ~/.ssh/config --color=none 2>/dev/null | awk '{print $2}' | sort`
}

function _ssh_hosts {
  compadd `grep 'Host ' ~/.ssh/config --color=none 2>/dev/null | awk '{print $2}' | sort`
}

# neovim
alias vim=nvim
case $(uname) in
  "Linux")
    export PATH="/opt/nvim-linux-x86_64/bin:$PATH"
    ;;
  "Darwin")
    export PATH="/opt/nvim-macos-arm64/bin:$PATH"
    ;;
esac

# git
export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes'

# android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/emulator:$PATH

if [ "$RUN_ZPROF" = true ]; then
    zprof | less
fi