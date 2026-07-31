# Dotfiles

My personal dotfiles managed with GNU Stow for Arch Linux with Hyprland ([Omarchy](https://github.com/omarchy)).

## Prerequisites

- Git
- GNU Stow
- Arch Linux (for `install.sh`)
- Fedora Linux (for `scripts/install-fedora.sh`)
- Hyprland-based Wayland desktop

## Installation

### 1. System Setup

Install required packages and dependencies:

```bash
chmod +x install.sh
./install.sh
```

### Fedora Setup

For Fedora Linux, use the dedicated Fedora installation script:

```bash
chmod +x scripts/install-fedora.sh
./scripts/install-fedora.sh
```

This will install:

- **Ghostty terminal**: Installed from COPR repository
- **Core utilities**: stow, btop, htop, fzf, zsh, man-db, tldr
- **Oh My Zsh**: With Powerlevel10k theme and plugins (autosuggestions, syntax-highlighting, zsh-bat)
- **System cleanup**: Removes existing ghostty and zsh configs before stowing new ones

Both installation scripts prepare the system with essential packages and shell environment, then deploy the dotfiles using stow.

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
├── scripts/                   # Installation and maintenance scripts
│   ├── install-fedora.sh      # Fedora package installation and config deployment
│   ├── install.sh             # Arch package installation and config deployment
│   └── theme.sh               # Switch the Catppuccin flavour across all configs
└── refresh.sh                 # Sync live configs back to repo
```

## Theming

Every themed config keeps a single **switcher line** that points at a
flavour-specific palette file. `scripts/theme.sh` rewrites those lines, so
switching the whole desktop is one command. Because `~/.config` is stowed into
this repo, editing here is what the running apps read.

```bash
./scripts/theme.sh              # show which flavour each config points at
./scripts/theme.sh latte        # switch everything to Catppuccin Latte
./scripts/theme.sh mocha        # ...or back to Mocha  (aliases: light / dark)
./scripts/theme.sh toggle       # flip between the two
```

| Keybind | Action |
| --- | --- |
| `ALT + CTRL + SHIFT + SPACE` | Rofi flavour picker |
| `ALT + CTRL + T` | Toggle Mocha ⇄ Latte |

## Monitor Modes

`ALT + CTRL + M` toggles `hypr/modules/monitors.lua` between mirroring the laptop
panel onto HDMI-A-1 and extending onto it. Like the theme switcher it rewrites a
single line (`local mode = "..."`) and reloads Hyprland, so the choice survives a
restart.

```bash
~/.config/hypr/scripts/monitor-mode.sh            # toggle
~/.config/hypr/scripts/monitor-mode.sh mirror     # duplicate the laptop panel
~/.config/hypr/scripts/monitor-mode.sh extend     # extend to its right
```

| Mode | HDMI-A-1 rule |
| --- | --- |
| `mirror` | `position = "auto"`, `mirror = "eDP-1"` |
| `extend` | `position = "1920x0"` — the laptop panel's width, so it sits to the right |

The rules apply whether or not the external display is plugged in; Hyprland
applies the matching rule when it connects.

### Where the colours live

| App | Switcher line | Palettes |
| --- | --- | --- |
| btop | `btop.conf` → `color_theme` | `btop/themes/catppuccin-*.theme` |
| ghostty | `config` → `config-file` | `ghostty/colors/catppuccin-*.conf` |
| waybar | `colors.css` | `waybar/colors/custom/catppuccin-*.css` |
| swaync | `colors.css` | `swaync/colors/catppuccin-*.css` |
| wlogout | `colors.css` | `wlogout/colors/catppuccin-*.css` |
| rofi | `shared/colors.rasi` | `rofi/colors/catppuccin-*.rasi` |
| hyprlock | `hypr/colors.conf` | `hypr/colors/catppuccin-*.conf` |
| hyprland borders | `modules/colors.lua` → `active` | same file (both flavours inline) |
| tmux | `tmux.conf` → `@catppuccin_flavor` | catppuccin/tmux plugin |
| nvim | `plugins/theme.lua` → `flavour` | catppuccin/nvim plugin |

The GTK apps (waybar, swaync, wlogout) import the raw 26-colour Catppuccin
palette and map it to semantic names in their own `style.css`, so palette files
stay pure colour definitions.

`hypr/scripts/wallpaper-picker.sh` reads the same flavour marker
(`modules/colors.lua`) and pulls from `~/Pictures/Wallpapers/catppuccin-<flavour>`,
falling back to `catppuccin-mocha` for flavours with no wallpapers of their own.
It has three modes:

| Mode | Behaviour |
| --- | --- |
| *(no args)* | rofi thumbnail picker for the active flavour's set |
| `--cycle` | advance to the next wallpaper in that set |
| `--sync` | used by `theme.sh`; sets one from the active flavour's set, but only if the current wallpaper is not already from it |

`theme.sh` calls `--sync` on every switch, so changing flavour also changes the
wallpaper. Because `--sync` is a no-op when the wallpaper already matches,
re-running a switch does not churn it.

### System light/dark mode

Latte puts the system into light mode and Mocha into dark mode. `theme.sh` sets:

| Setting | Latte | Mocha |
| --- | --- | --- |
| `org.gnome.desktop.interface color-scheme` | `prefer-light` | `prefer-dark` |
| `org.gnome.desktop.interface gtk-theme` | `Catppuccin-BL-MB-Light` | `Catppuccin-BL-MB-Dark` |
| `gtk-3.0`/`gtk-4.0` `settings.ini` | `prefer-dark-theme=0` | `prefer-dark-theme=1` |
| `~/.config/gtk-4.0/{gtk.css,gtk-dark.css,assets}` | symlinked to the Light theme | symlinked to the Dark theme |

The `color-scheme` key is what `xdg-desktop-portal` exposes as
`org.freedesktop.appearance`, so libadwaita, Electron and Chromium apps follow it
too. The GTK theme pair is set via `GTK_THEME_LIGHT` / `GTK_THEME_DARK` at the
top of `scripts/theme.sh` — change those if you install a different pair under
`~/.themes`; the script warns and leaves the GTK theme alone if the named theme
is missing.

Note these GTK files live in `~/.config` and are **not** stowed from this repo,
so `theme.sh` edits them in place. Only existing symlinks under `gtk-4.0/` are
re-pointed — real files there are never overwritten.

### What reloads live

`waybar`, `swaync`, `hyprland` borders, `tmux` and `ghostty` are reloaded by the
script. Ghostty does not watch its config file, so it is reloaded through the
same `reload-config` action its menu uses, called on the session bus:

```bash
gdbus call --session --dest com.mitchellh.ghostty \
  --object-path /com/mitchellh/ghostty \
  --method org.gtk.Actions.Activate reload-config "[]" "{}"
```

**btop, rofi, wlogout, hyprlock and nvim pick up the new flavour the next time
they launch** — there is no live-reload path for those. `htop` has no custom
theme support at all; with `color_scheme=0` it follows the terminal palette, so
it changes with ghostty.

Within `theme.sh` the order matters: palette files, `settings.ini` and the
GTK4 symlinks are all written *before* the dconf keys are set. Apps watch dconf
and re-read their theme the instant it changes, so the files they read must
already be correct — otherwise a fast-reacting app loads the previous theme.

tmux needs one extra step. `catppuccin/tmux` assigns both its palette (`@thm_*`)
and its derived per-module colours (`@catppuccin_status_*_text_fg`, `*_icon_fg`)
with `set -ogqF`. `-F` bakes the colour to a literal hex at source time, and `-o`
then refuses to overwrite an option that is already set — so re-sourcing
`tmux.conf` alone keeps the *previous* flavour. `theme.sh` clears everything
catppuccin-owned first and lets the plugin rebuild it:

```bash
tmux show -g | grep -oE '^@(thm|catppuccin)[a-z_0-9]*' | while read -r opt; do
  tmux set -gu "$opt"
done
tmux source-file ~/.config/tmux/tmux.conf
```

Clearing only `@thm_*` is not enough: the palette updates but the module colours
stay baked, which shows up as e.g. the session name keeping light Mocha text on a
light Latte background.

Also note the palette exposes the base colour as **`@thm_bg`** — there is no
`@thm_base`. Referencing a non-existent option expands to an empty string, which
leaves tmux's default green status bar showing.

### Adding a flavour

Add a palette file per app using the existing names, then add the flavour to
`FLAVOURS` in `hypr/scripts/theme-picker.sh` and to the `case` in
`scripts/theme.sh`. Mocha and Latte are complete; the `everforest` and
`rose-pine` files under `waybar`, `swaync`, `wlogout` and `rofi` are older
partial leftovers and are not wired into the switcher.

If you add a whole new *directory* to a package (rather than a file inside an
existing one), run `stow -R <package>` so it gets symlinked — ghostty's
`colors/` needed this because `~/.config/ghostty` holds an unmanaged file and so
is not tree-folded.

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
- Catppuccin is the consistent theme across all tools; switch flavour with `scripts/theme.sh` (see [Theming](#theming))
- Always review changes before committing updated configurations

### Installation Methods

- **Arch Linux**: Uses `install.sh` with `pacman` and AUR helpers (yay/paru) for package management
- **Fedora Linux**: Uses `scripts/install-fedora.sh` with `dnf` and COPR repositories for package management
- Both scripts achieve similar end states (essential packages + shell environment) but use different package managers and sources
