# dotfiles

## Tool management

[mise](https://mise.jdx.dev/) is used for tool management, with the following exceptions:

- **cargo**: Installed directly via rustup. [Using mise provides little benefit](https://mise.jdx.dev/lang/rust.html#rust).
- **Haskell tools** (ghc, cabal, ...): Managed by ghcup, which is installed via mise.

## Adding command completions

To add command completion, add the following to `zsh/plugins.toml`:

```toml
[plugins.<command>-completion]
inline = 'on_demand_completion "<command>" "<completion-generate-command>"'
```

Examples:

```toml
# When a completion generation command is available
[plugins.gh-completion]
inline = 'on_demand_completion "gh" "gh completion -s zsh"'

# When the command provides completion files itself (e.g., docker)
[plugins.docker-completion]
inline = 'on_demand_completion "docker"'
```

After adding, run `sheldon lock --reinstall` to apply.

## Adding PATH for tools not managed by mise

For tools not managed by mise (e.g., rustup, ghcup), add their env file to `[plugins.tool-envs]` in `zsh/plugins.toml`:

```toml
[plugins.tool-envs]
inline = '''
zsh-defer -c '[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"'
zsh-defer -c '[[ -f "$HOME/.ghcup/env" ]] && . "$HOME/.ghcup/env"'
'''
```

After adding, run `sheldon lock --reinstall` to apply.

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

