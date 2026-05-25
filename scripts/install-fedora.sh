#!/usr/bin/env bash

set -e

sudo dnf update

echo "Installing ghostty from COPR..."
sudo dnf copr enable scottames/ghostty -y
sudo dnf install ghostty -y

PACKAGES=(
  btop
  htop
  fzf
  man-db
  man-pages
  nano
  os-prober
  stow
  tldr
  zip
  unzip
  zsh
)

sudo dnf install "${PACKAGES[@]}" -y

echo "✔ All packages installed"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh already installed. Skipping."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_plugin() {
  local repo="$1"
  local dest="$2"
  if [ -d "$dest" ]; then
    echo "Plugin already exists: $dest. Skipping."
  else
    echo "Installing plugin: $dest"
    git clone https://github.com/"$repo".git "$dest"
  fi
}

clone_plugin "zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_plugin "zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_plugin "romkatv/powerlevel10k" "$ZSH_CUSTOM/themes/powerlevel10k"
clone_plugin "fdellwing/zsh-bat" "$ZSH_CUSTOM/plugins/zsh-bat"

rm -rf "$HOME/.config/ghostty"
rm -rf "$HOME/.zshrc"

cd "$HOME/dotfiles"
stow ghostty zsh

echo "All configs installed!"

if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
else
  echo "Zsh is already the default shell. Skipping."
fi

echo "Please restart your terminal to apply changes."
