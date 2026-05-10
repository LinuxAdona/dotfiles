# Dotfiles

My personal dotfiles managed with GNU Stow for Arch Linux with Hyprland ([Omarchy](https://github.com/omarchy)).

## Prerequisites

- Git
- GNU Stow
- Arch Linux (for `install.sh`)
- Hyprland-based Wayland desktop

## Installation

### 1. System Setup

Install required packages and dependencies:

```bash
chmod +x install.sh
./install.sh
```

This will install:

- **AUR helper**: yay (installed automatically if not present)
- **Core utilities**: stow, cmake, base-devel, openssh, github-cli
- **Development tools**: neovim, git, nodejs, npm, php, filezilla
- **Shell environment**: zsh (with Oh My Zsh, Powerlevel10k, autosuggestions, syntax-highlighting), yazi, tmux (with TPM), zoxide
- **Hyprland ecosystem**: hyprland, hyprpaper, hypridle, hyprlock, waybar, rofi, wofi, swaync, wlogout
- **Wayland utilities**: wl-clipboard, cliphist, brightnessctl, playerctl, wpctl, pamixer, bluetui
- **System utilities**: curl, wget, flatpak, pavucontrol, piper, kalarm
- **Styling**: otf-commit-mono-nerd, cmatrix
- **AUR packages**: waybar-module-pacman-updates-git, wttrbar, bibata-cursor-theme, brave-bin, paru, snapd, tty-clock

### 2. Deploy Dotfiles

Clone this repository and deploy configurations using stow:

```bash
git clone https://github.com/itslinxad/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

#### Deploy all packages

```bash
stow ghostty hypr nvim omarchy opencode tmux waybar zsh
```

#### Deploy specific packages

Each top-level directory is a stow package. Deploy individual packages by name:

```bash
stow nvim       # Deploy Neovim config to ~/.config/nvim/
stow hypr       # Deploy Hyprland config to ~/.config/hypr/
stow waybar     # Deploy Waybar config to ~/.config/waybar/
stow tmux       # Deploy tmux config to ~/.tmux.conf
stow zsh        # Deploy Zsh config to ~/.zshrc
```

## Usage

### Unstow Configurations

To remove symlinks and unstow all packages:

```bash
cd ~/dotfiles
stow -D ghostty hypr nvim omarchy opencode tmux waybar zsh
```

Or unstow a specific package:

```bash
stow -D nvim
```

## Repository Structure

Each top-level directory is a **stow package** that mirrors the target path from `$HOME`:

```
dotfiles/
├── ghostty/                   # Ghostty terminal emulator
│   └── .config/ghostty/
│       ├── config
│       └── shaders/           # Custom GLSL cursor shaders
├── hypr/                      # Hyprland compositor
│   └── .config/hypr/
│       ├── hyprland.conf
│       ├── bindings.conf
│       ├── monitors.conf
│       ├── input.conf
│       ├── looknfeel.conf
│       ├── autostart.conf
│       ├── hypridle.conf
│       ├── hyprlock.conf
│       ├── hyprsunset.conf
│       └── xdph.conf
├── nvim/                      # Neovim (LazyVim-based)
│   └── .config/nvim/
│       ├── init.lua
│       ├── lazy-lock.json
│       └── lua/
│           ├── config/
│           └── plugins/
├── omarchy/                   # Omarchy theme framework
│   └── .config/omarchy/
│       └── themes/itslinx/    # Custom "itslinx" theme
├── opencode/                  # OpenCode editor
│   └── .config/opencode/
│       └── opencode.json
├── tmux/                      # Tmux
│   └── .tmux.conf
├── waybar/                    # Waybar status bar
│   └── .config/waybar/
│       ├── config.jsonc
│       └── style.css
├── zsh/                       # Zsh shell
│   └── .zshrc
├── btop/                      # btop system monitor
│   └── .config/btop/
├── rofi/                      # Rofi app launcher
│   └── .config/rofi/
├── swaync/                    # Sway notification center
│   └── .config/swaync/
├── wlogout/                   # Wlogout menu
│   └── .config/wlogout/
├── install.sh                 # System package installation script
└── refresh.sh                 # Sync live configs back to repo
```

## Stow Commands Reference

| Command | Description |
| --- | --- |
| `stow <package>` | Create symlinks for a package |
| `stow -D <package>` | Remove symlinks for a package (unstow) |
| `stow -R <package>` | Restow a package (useful after updates) |
| `stow -n <package>` | Dry run (preview changes) |
| `stow -v <package>` | Verbose output |

## Notes

- Each top-level directory is a stow package that mirrors the target path from `$HOME`
- Configs under `.config/` are stored as `<package>/.config/<app>/` so stow symlinks them correctly
- Root-level dotfiles (`.zshrc`, `.tmux.conf`) are stored directly inside their package directory
- Use `refresh.sh` to pull changes from your live system back into this repo (destructive copy -- deletes then re-copies)
- Catppuccin Mocha is the consistent theme across all tools
- Always review changes before committing updated configurations
