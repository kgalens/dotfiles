# dotfiles

Personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a Stow package whose internal path mirrors where
it lands under `$HOME`.

## Layout

| Package | Installs to |
|---|---|
| `nvim/` | `~/.config/nvim` (Neovim + LazyVim, Python LSP/DAP/test setup) |
| `kitty/` | `~/.config/kitty/kitty.conf` |
| `zsh/` | `~/.zshrc`, `~/.p10k.zsh` (oh-my-zsh + Powerlevel10k) |
| `tmux/` | `~/.tmux.conf` |
| `git/` | `~/.gitconfig` |
| `asdf/` | `~/.tool-versions` (Python/Node/Go versions via [asdf](https://asdf-vm.com/)) |
| `Brewfile` | Homebrew formulae/casks — install with `brew bundle install` |
| `legacy/` | Old bash/iTerm2/screen/Vundle-vim config, kept for reference only. Not installed by anything here. |

## New machine setup

```sh
git clone git@github.com:kgalens/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent — it installs Homebrew if missing, runs
`brew bundle install`, installs oh-my-zsh + Powerlevel10k if missing, stows
every package into `$HOME`, installs the asdf language versions from
`.tool-versions`, and syncs Neovim's plugins (including `debugpy` for
Python debugging).

## Adding/updating a package by hand

```sh
cd ~/dotfiles
stow -v -t ~ <package>      # (re)create symlinks for one package
stow -v -D -t ~ <package>   # remove them
```

After installing, add anything newly `brew install`ed to the Brewfile with:

```sh
brew bundle dump --file=Brewfile --force
```
