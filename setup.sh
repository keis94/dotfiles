#!/bin/bash

set -euo pipefail

source ./utils
export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
PLATFORM=$(platform)
TOOLS_PACKAGE_MANAGER=(zsh git tmux fzf unzip)
TOOLS_MISE=(usage gh node@lts bun uv ghcup)
DOTFILES=(
  ".tmux.conf $HOME/.tmux.conf"
  "zsh/.zshenv $HOME/.zshenv"
  "zsh/plugins.toml $HOME/.config/sheldon/plugins.toml"
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
  local with_sudo=0

  while (($#)); do
    case "$1" in
      --sudo)    with_sudo=1; shift ;;
      --)        shift; break ;;  # ここから先はポジション引数
      -*)        echo "Unknown option: $1" >&2; return 2 ;;
      *)         break ;;
    esac
  done

  if (($# != 2)); then
    echo "Usage: ensure_symlink [--sudo] -- <src> <dest>" >&2
    return 2
  fi

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
  if ((with_sudo)); then
    sudo ln -sfn "$src" "$dest"
  else
    ln -sfn "$src" "$dest"
  fi
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

# Claude code
if is_missing claude; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# rustup
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
if is_missing rustup; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  . "$HOME/.cargo/env"
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
if is_missing /opt/nvim-*/bin/nvim; then
  case $PLATFORM in
    Linux)
      curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    ;;
    Mac)
      curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz
    ;;
  esac
  sudo rm -rf /opt/nvim-*
  sudo tar -C /opt -xzf nvim-*.tar.gz
  rm ./nvim-*.tar.gz
fi

info_log "Install tools with the package manager"
for tool in ${TOOLS_PACKAGE_MANAGER[@]}; do
  install_package $tool
done

info_log "Install tools with mise"
for tool in ${TOOLS_MISE[@]}; do
  mise_install $tool
done

# python
if [[ "$(command -v python3)" != *"/.local/bin/"* ]]; then
  info_log "Use uv's python and python3, overwriting the current ones."
  uv python install --default
fi

# haskell
if [[ ! -f "$HOME/.ghcup/env" ]]; then
  # TODO: support macOS
  install_package build-essential
  ghcup install ghc --set recommended
  ghcup install cabal --set recommended
  ghcup install hls --set recommended
  # ~/.ghcup/env is not installed in ghcup 0.1.50.2 when using mise
  cp ghcup/ghcup-env ~/.ghcup/env
fi

info_log "Replace dotfiles"
for entry in "${DOTFILES[@]}"; do
  ensure_symlink $entry
done

# WSL
if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
  info_log "WSL detected. Run \"wsl --shutdown\" to apply the settings when it's updated."
  ensure_symlink --sudo wsl.conf /etc/wsl.conf
  # appendWindowsPath is false, so manually set symlink for launching windows apps
  # (vscode only, at the time of writing)
  if [[ -f "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin/code" ]]; then
    ensure_symlink --sudo "/mnt/c/Users/$USER/AppData/Local/Programs/Microsoft VS Code/bin/code" /usr/local/bin/code
  fi
fi

info_log "Configure git"
git config --global pull.rebase true
git config --global user.name "keis94"
git config --global user.email "keis.vivi@gmail.com"
git config --global core.editor "nvim"

info_log "Install sheldon"
if is_missing sheldon; then
  case $PLATFORM in
    Linux)
      for package in build-essential libssl-dev pkg-config; do
        install_package $package
      done
      ;;
    Mac)
      for package in openssl pkg-config; do
        install_package $package
      done
      ;;
  esac
  cargo install sheldon
fi
# Initialize sheldon plugins
zsh -c "sheldon lock"

if ! (locale -a | grep -i en_us.UTF8 > /dev/null 2>&1); then
  case $PLATFORM in
    Linux)
      info_log "Generate locale en_US.utf8"
      if is_missing locale-gen; then
        install_package locales
      fi
      sudo locale-gen en_US.utf8
      ;;
    Mac)
      error_log """locale en_US.utf8 is not found. Create it manually
      see: https://apple.stackexchange.com/questions/384388/how-to-add-a-new-locale-to-macos-catalina
      """
      ;;
  esac
fi

# chsh
current_shell=$(
  grep "$USER" /etc/passwd | awk -F':' '{print $7}'
)
zsh_path="$(command -v zsh)"
if [[ "$current_shell" != "$zsh_path" ]]; then
  info_log "Set zsh as default shell. Input password for chsh:"
  chsh -s "$zsh_path"
fi

exec zsh -l

