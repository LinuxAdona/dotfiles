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

## Services

System services and daemon configurations are stored in the `services/` directory. These are not managed by Stow and require manual installation.

### Auto Power Profile

Automatically switches system power profiles based on AC adapter status and battery capacity using `power-profiles-daemon`.

**What it does:**
- Sets **performance** mode when AC is plugged in
- Sets **power-saver** mode when battery capacity ≤ 30%
- Sets **balanced** mode when battery is between 31-80%
- Runs on system boot and automatically adjusts when power state changes

**How it works:**
- `auto-power-profile.service` - systemd service that runs the script on boot
- `99-auto-power-profile.rules` - udev rules that trigger the script when AC adapter connects/disconnects
- `auto-power-profile.sh` - shell script that detects power state and sets appropriate profile

**Installation:**

1. **Verify your battery device path:**
   ```bash
   ls /sys/class/power_supply/
   # Look for BAT0, BAT1, or similar battery device
   ```

2. **Update battery path if needed:**
   Edit `services/auto-power-profile.sh` and change `BATTERY_PATH` if your device is not `BAT0`:
   ```bash
   BATTERY_PATH="/sys/class/power_supply/BAT0"  # Change BAT0 to your device
   ```

3. **Copy files to system directories:**
   ```bash
   sudo cp services/auto-power-profile.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/auto-power-profile.sh
   sudo cp services/99-auto-power-profile.rules /etc/udev/rules.d/
   sudo cp services/auto-power-profile.service /etc/systemd/system/
   ```

4. **Enable and start the service:**
   ```bash
   sudo systemctl enable auto-power-profile.service
   sudo systemctl start auto-power-profile.service
   ```

5. **Reload udev rules:**
   ```bash
   sudo udevadm control --reload
   sudo udevadm trigger
   ```

**Configuration:**

The script uses these thresholds:
- **AC Connected** → `performance` mode
- **Battery ≤ 30%** → `power-saver` mode
- **Battery 31-80%** → `balanced` mode
- **Battery > 80%** → `balanced` mode

Edit `services/auto-power-profile.sh` to adjust capacity thresholds (lines 17-22).

**Verification & Troubleshooting:**

1. **Check service status:**
   ```bash
   systemctl status auto-power-profile.service
   ```

2. **Check current power profile:**
   ```bash
   powerprofilesctl get
   ```

3. **List available profiles:**
   ```bash
   powerprofilesctl list
   ```

4. **Verify power-profiles-daemon is running:**
   ```bash
   systemctl status power-profiles-daemon.service
   ```

5. **Check if udev rules are loaded:**
   ```bash
   sudo udevadm info --name=/sys/class/power_supply/AC
   ```

6. **View systemd journal logs:**
   ```bash
   journalctl -u auto-power-profile.service -n 20
   ```

7. **Test the script manually:**
   ```bash
   sudo /usr/local/bin/auto-power-profile.sh
   ```

8. **Check AC and battery status directly:**
   ```bash
   cat /sys/class/power_supply/AC/online        # 1 = plugged in, 0 = unplugged
   cat /sys/class/power_supply/BAT0/capacity    # Battery percentage
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
├── services/                  # System services and daemons
│   ├── auto-power-profile.sh          # Power profile management script
│   ├── auto-power-profile.service     # systemd service unit
│   └── 99-auto-power-profile.rules    # udev rules for AC/battery events
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
