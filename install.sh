#!/usr/bin/env bash
# Bootstrap a new Mac from this dotfiles repo.
# Safe to re-run: every step here is idempotent.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(nvim kitty zsh tmux git asdf)

echo "==> Dotfiles directory: $DOTFILES_DIR"

# 1. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2. Homebrew packages (formulae + casks)
echo "==> brew bundle install"
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# 3. oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 4. Powerlevel10k theme (zsh plugins used in .zshrc all ship with oh-my-zsh core)
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "==> Cloning Powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# 5. Stow every package into $HOME (backs off if a real file is already there)
echo "==> Stowing dotfiles"
for pkg in "${PACKAGES[@]}"; do
  if ! stow -n -t "$HOME" "$pkg" >/dev/null 2>&1; then
    echo "    WARNING: $pkg has conflicts with existing files in \$HOME - skipping, resolve manually then run: stow -t \$HOME $pkg"
    continue
  fi
  stow -v -t "$HOME" "$pkg"
done

# 6. asdf language versions (reads $HOME/.tool-versions, stowed above)
echo "==> asdf plugins + install"
# shellcheck disable=SC1091
. "$(brew --prefix asdf)/libexec/asdf.sh"
for plugin in python nodejs golang; do
  asdf plugin add "$plugin" 2>/dev/null || true
done
(cd "$HOME" && asdf install)

# 7. Neovim: install plugins + debugpy
echo "==> Neovim: syncing plugins"
nvim --headless "+Lazy! sync" +qa

echo "==> Neovim: installing debugpy via Mason"
nvim --headless -c '
lua
local reg = require("mason-registry")
reg.refresh(function()
  local pkg = reg.get_package("debugpy")
  if pkg:is_installed() then
    vim.schedule(function() vim.cmd("qa!") end)
  else
    pkg:install():once("closed", function()
      vim.schedule(function() vim.cmd("qa!") end)
    end)
  end
end)
'

echo "==> Done. Restart your terminal (or open a new Kitty window) to pick everything up."
