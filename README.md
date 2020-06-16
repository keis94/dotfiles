# dotfiles

## Install

```zsh
git clone https://github.com/keis94/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.zsh
```

## Test

When you want to check that `setup.zsh` works well in clean environment, run following commands.

Local changes in this repository will be applyed in test environment.

```zsh
# In your terminal
cd ~/.dotfiles
docker build -t dotfiles-test
docker run --rm -it dotfiles-test

# Inside container
./install.zsh
```

