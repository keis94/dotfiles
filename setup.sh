#!/bin/bash

set -euo pipefail

source ./utils
export PATH="$HOME/.local/bin:$PATH"
PLATFORM=$(platform)
TOOLS_PACKAGE_MANAGER=(zsh git tmux fzf unzip)
TOOLS_MISE=(gh node@lts bun uv)
DOTFILES=(
  ".tmux.conf $HOME/.tmux.conf"
  "zsh/.zshenv $HOME/.zshenv"
  "zsh/.zplug $HOME/.zplug"
  "nvim $HOME/.config/nvim"
)

is_missing () {
  local tool="$1"

  if ! command -v "$tool" >/dev/null 2>&1; then
    info_log "${tool} will be installed"
    return 0
  fi
  return 1
}

ensure_symlink () {
  local src=$(realpath "$1")
  local dest="$2"

  if [[ -L "$dest" && $(readlink "$dest") == "$src" ]]; then
    return 0
  fi

  # If the target already exists (but isn't a symlink), back it up or delete it first.
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "Warning: $dest already exists. Backing up to $dest.bak"
    mv "$dest" "${dest}.bak"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$src" "$dest"
  info_log "Linked: $dest -> $src"
}

install_package () {
  local tool="$1"

  if ! is_missing "$tool"; then
    info_log "$tool has been installed"
    return 0
  fi

  info_log "Installing $tool with the package manager"
  case $PLATFORM in
    Linux)
      if [[ -z "${APT_UPDATE_DONE:-}" ]]; then
        sudo apt-get update
        APT_UPDATE_DONE=1
      fi
      sudo apt install -y "$tool"
      ;;
    Mac)
      brew install "$tool"
      ;;
  esac
}

mise_install () {
  local spec="$1"
  local tool="${spec%%@*}"

  if ! is_missing "$tool"; then
    info_log "$tool has been installed"
    return 0
  fi

  info_log "Installing $tool with mise"
  mise install "$spec"
  mise use "$spec" --global
}

source ./utils
PLATFORM=$(platform)

if [ $PLATFORM = 'UNKNOWN' ]; then
  error_log 'Failed to identify your platform. exiting...'
  exit -1
fi

if [ $PLATFORM = 'Mac' ]; then
  info_log 'Installing brew'
  # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi


info_log "Installing tools with the setup scripts"
# mise
if is_missing mise; then
  curl https://mise.run | sh
fi

# uv
if is_missing uv; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  uv python install --default
fi

# Claude code
if is_missing claude; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# docker
if is_missing docker; then
  case $PLATFORM in
  Linux)
    info_log "adding keyrings and apt source..."
    # https://docs.docker.com/engine/install/ubuntu/
    sudo apt update
    sudo apt install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ;;
  Mac)
    info_log "install colima instead of Docker Desktop"
    brew install colima
    ;;
  esac
fi

# neovim
if is_missing nvim; then
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
  rm ./nvim-linux-x86_64.tar.gz
fi

info_log "Install tools with the package manager"
for tool in ${TOOLS_PACKAGE_MANAGER[@]}; do
  install_package $tool
done

info_log "Install tools with the package manager"
for tool in ${TOOLS_MISE[@]}; do
  mise_install $tool
done

if [[ "$(which python3)" != *"/.local/bin/"* ]]; then
  info_log "Use uv's python and python3, overwriting the current ones."
  uv python install --default
fi

info_log "Replace dotfiles"
for entry in "${DOTFILES[@]}"; do
  ensure_symlink $entry
done

# WSL
if [ /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  info_log "WSL detected. Run \"wsl --shutdown\" to apply the settings when it's updated."
  ensure_symlink wsl.conf /etc/wsl.conf
fi

info_log "Configure git"
git config --global pull.rebase true
git config --global user.name "keis94"
git config --global user.email "keis.vivi@gmail.com"
git config --global core.editor "nvim"

info_log "Install zplug + prezto"
export ZPLUG_HOME=$HOME/repo/dotfiles/zsh/.zplug
[ ! -e $ZPLUG_HOME ] && git clone https://github.com/zplug/zplug $ZPLUG_HOME
zsh -ci "zplug install"
# workaround: setting Prezto config directory after `zplug install`
ln -sin $ZPLUG_HOME/repos/sorin-ionescu/prezto $HOME/.zprezto

info_log "Generate locale en_US.utf8"
sudo locale-gen en_US.utf8

info_log "zplug install"
zsh -ci 'source $ZDOTDIR/.zshrc; zplug install'

chsh -s /bin/zsh
exec zsh -li
