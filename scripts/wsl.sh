#!/usr/bin/env bash
#
# Arch-on-WSL setup: the terminal-only subset of this repo.
#
# Installs the CLI toolchain, configures git/SSH/Oh My Zsh, then stows the
# packages that make sense without a graphical session:
#
#   btop  htop  nvim  tmux  zsh
#
# Everything Wayland — hypr, waybar, rofi, swaync, wlogout, ghostty — is
# skipped. Use scripts/install.sh on a real Arch desktop for those.

set -e

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/mdk-zero/dotfiles.git"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

if ! grep -qi microsoft /proc/version 2>/dev/null; then
  echo "This does not look like WSL. scripts/install.sh is the full desktop version."
  read -rp "Continue anyway? (y/N): " answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 1
fi

sudo pacman -Sy --noconfirm

if ! command -v yay &>/dev/null; then
  echo "yay not found. Installing from AUR..."
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd /tmp && rm -rf yay
else
  echo "yay already installed. Skipping."
fi

PACKAGES=(
  base-devel
  github-cli
  openssh
  stow
)

DEV_PACKAGES=(
  git
  libnsl
  libxcrypt-compat
  neovim
  nodejs
  npm
  nvm
  php
  python
  python-pip
  python-pipx
)

SHELL_PACKAGES=(
  bat
  fzf
  tmux
  yazi
  zoxide
  zsh
)

UTIL_PACKAGES=(
  btop
  curl
  fd
  htop
  man-db
  man-pages
  ripgrep
  tldr
  unzip
  wget
  zip
)

# Nerd fonts are deliberately absent: under WSL the terminal is a Windows
# application and renders with fonts installed on the Windows side, so
# installing them in the distro does nothing for the p10k prompt or nvim icons.

AUR_PACKAGES=(
  paru
)

sudo pacman -S --needed --noconfirm \
  "${PACKAGES[@]}" \
  "${DEV_PACKAGES[@]}" \
  "${SHELL_PACKAGES[@]}" \
  "${UTIL_PACKAGES[@]}"

yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

if command -v composer &>/dev/null; then
  echo "Composer already installed. Skipping."
else
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php -r "if (hash_file('sha384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
  php composer-setup.php
  php -r "unlink('composer-setup.php');"
  sudo mv composer.phar /usr/local/bin/composer
fi

echo "✔ All packages installed"

git config --global user.name "Linux Adona"
git config --global user.email "linuxadona17@gmail.com"
git config --global init.defaultBranch main

SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
  echo "Generating new SSH key for GitHub..."
  ssh-keygen -t ed25519 -C "linuxadona17@gmail.com" -f "$SSH_KEY" -N ""
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"
  echo "Authenticating with GitHub CLI..."
  gh auth login -p ssh -h github.com -w
  gh ssh-key add "${SSH_KEY}.pub" --title "$(hostname)"
else
  echo "SSH key already exists at $SSH_KEY. Skipping generation."
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"
fi

echo "✔ SSH setup done"

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

# These must live under $ZSH_CUSTOM — the plugins=(...) list in zsh/.zshrc
# resolves names there, not against system-wide package installs.
clone_plugin "zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_plugin "zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_plugin "romkatv/powerlevel10k" "$ZSH_CUSTOM/themes/powerlevel10k"
clone_plugin "MichaelAquilina/zsh-you-should-use" "$ZSH_CUSTOM/plugins/zsh-you-should-use"
clone_plugin "fdellwing/zsh-bat" "$ZSH_CUSTOM/plugins/zsh-bat"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles into $DOTFILES_DIR..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

install_config() {
  local name="$1"
  local package="$2"

  echo ""
  echo "Installing $name config..."

  local conflicts
  conflicts=$(stow --no "$package" 2>&1 || true)

  if echo "$conflicts" | grep -q "existing target"; then
    echo "Conflict detected for $name."

    local conflicting_files
    conflicting_files=$(echo "$conflicts" | grep "existing target" |
      sed 's/.*over existing target //' |
      sed 's/ since .*//' |
      sed 's/.*existing target is not owned by stow: //' |
      sed 's/^[[:space:]]*//')

    echo "The following files/directories conflict:"
    echo "$conflicting_files" | while read -r f; do
      echo "  ~/$f"
    done

    read -rp "Back up existing files and install $name config? (y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      mkdir -p "$BACKUP_DIR"
      echo "$conflicting_files" | while read -r f; do
        local src="$HOME/$f"
        if [ -e "$src" ] || [ -L "$src" ]; then
          local backup_dest="$BACKUP_DIR/$f"
          mkdir -p "$(dirname "$backup_dest")"
          if [ -L "$src" ]; then
            rm "$src"
            echo "  Removed stale symlink: ~/$f"
          else
            mv "$src" "$backup_dest"
            echo "  Backed up: ~/$f -> $BACKUP_DIR/$f"
          fi
        fi
      done

      echo "$conflicting_files" | while read -r f; do
        local parent
        parent=$(dirname "$HOME/$f")
        while [ "$parent" != "$HOME" ] && [ -d "$parent" ]; do
          if [ -z "$(ls -A "$parent" 2>/dev/null)" ]; then
            rmdir "$parent"
          else
            break
          fi
          parent=$(dirname "$parent")
        done
      done

      stow "$package"
      echo "✔ $name config installed (old files backed up to $BACKUP_DIR)"
    else
      echo "Skipped $name config."
      return
    fi
  else
    stow "$package"
    echo "✔ $name config installed"
  fi
}

install_config "Btop" "btop"
install_config "Htop" "htop"
install_config "Neovim" "nvim"
install_config "Tmux" "tmux"
install_config "Zsh" "zsh"

# TPM is not cloned here on purpose: tmux/.config/tmux/tmux.conf bootstraps it
# into ~/.local/share/tmux/plugins/tpm on first launch and installs the plugin
# list itself. Cloning to the old ~/.tmux/plugins/tpm path just leaves a second,
# unused copy behind.

if [ "$(basename "$SHELL")" != "zsh" ]; then
  echo ""
  echo "Changing default shell to zsh..."
  chsh -s "$(command -v zsh)"
else
  echo "Zsh is already the default shell. Skipping."
fi

echo ""
echo "All configs installed!"
echo "Start a new zsh session; tmux will install its plugins on first launch."
