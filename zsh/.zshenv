# Skip system compinit in /etc/zsh/zshrc (Ubuntu)
skip_global_compinit=1

# XDG Base Directory
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache
export XDG_STATE_HOME=$HOME/.local/state

# .zshenv is a symlink to the dotfiles repository,
# so ZDOTDIR is set to its zsh directory (found by following the symlink).
local zshenv_origin_path="${${(%):-%x}:P}"
export ZDOTDIR=$(dirname "$zshenv_origin_path")

# Enable zsh profiling
RUN_ZPROF=${RUN_ZPROF:-false}

if [ "$RUN_ZPROF" = true ]; then
    zmodload zsh/zprof && zprof
fi

# Locale
export LANG="en_US.UTF-8"

# MISE Trusted Directory
# ./mise needs to be added so that the setup script can run mise install without prompting.
local mise_config_path="$XDG_CONFIG_HOME/mise/config.toml"
local mise_config_dir=$(dirname "${mise_config_path:P}")
export MISE_TRUSTED_CONFIG_PATHS="$mise_config_dir:$XDG_CONFIG_HOME/mise"

