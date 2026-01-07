# dotfiles

## Adding new tool env files

To load a new tool's env file (e.g., `~/.new-tool/env`) with deferred loading, add the following to `zsh/plugins.toml` in the `[plugins.tool-envs]` section:

```toml
[plugins.tool-envs]
inline = '''
...
zsh-defer -c '[[ -f "$HOME/.new-tool/env" ]] && . "$HOME/.new-tool/env"'
'''
```

Then run `sheldon lock --reinstall` to apply.

## Install

```shell
git clone https://github.com/keis94/dotfiles.git ~/repo/dotfiles
cd ~/repo/dotfiles
./setup.sh
```

## Test

When you want to check that `setup.sh` works well in clean environment, run following commands.

Local changes in this repository will be applyed in test environment.

```shell
# In your terminal
cd ~/repo/dotfiles
docker build -t dotfiles .
docker run --rm -it dotfiles

# Inside container
./setup.sh
```

