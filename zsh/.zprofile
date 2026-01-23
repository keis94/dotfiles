#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
path=(
  /usr/local/{bin,sbin}
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

# https://github.com/wezterm/wezterm/issues/5503#issuecomment-2600490028
# Function to send the current working directory to WezTerm
function __wezterm_osc7() {
  if hash wezterm 2>/dev/null; then
    # Use WezTerm's helper command to set the working directory if available
    wezterm set-working-directory 2>/dev/null && return
  fi
  # Fallback: Send the current working directory to the terminal using OSC 7
  printf "\033]7;file://%s%s\033\\" "${HOSTNAME}" "${PWD}"
}

# Hook to execute the function after every interactive command
precmd_functions+=(__wezterm_osc7)

eval "$(~/.local/bin/mise activate zsh)"
