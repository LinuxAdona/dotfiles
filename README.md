# Dotfiles

Personal dotfiles managed with GNU Stow — an Arch Linux + Hyprland desktop,
themed end to end with Catppuccin and switchable between Mocha and Latte with a
single command.

## Prerequisites

- Git and GNU Stow
- Arch Linux (`scripts/install.sh`) — the full desktop setup
- Fedora Linux (`scripts/install-fedora.sh`) — terminal subset only
- Arch on WSL (`scripts/wsl.sh`) — terminal subset only
- A Hyprland session for the desktop packages

## Installation

Clone the repo first — every install script stows out of `~/dotfiles`:

```bash
git clone git@github.com:mdk-zero/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Arch Linux (full desktop)

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

Installs the packages, sets up git/SSH/Oh My Zsh, stows every package, and
installs Spicetify with its Marketplace. Roughly:

- **AUR helpers**: yay (bootstrapped from source if missing), paru
- **Core**: stow, base-devel, cmake, openssh, github-cli, man-db, man-pages, tldr, unzip, zip
- **Development**: neovim, git, nodejs, npm, nvm, php, python, python-pip, python-pipx, jdk17-openjdk, android-studio + android-sdk, filezilla, opencode, composer (installed from getcomposer.org)
- **Shell**: zsh (Oh My Zsh, Powerlevel10k, autosuggestions, syntax-highlighting, you-should-use, zsh-bat), tmux, yazi, zoxide, fzf, btop, htop
- **Hyprland ecosystem**: hypridle, hyprlock, hyprpicker, hyprshot, hyprshutdown, hyprpolkitagent, xdg-desktop-portal-hyprland, rofi, swaync, swayosd, wlogout, awww (wallpaper daemon), and waybar via `waybar-cava-git` + `waybar-module-pacman-updates`
- **Wayland/system**: wl-clipboard, cliphist, brightnessctl, pamixer, pavucontrol, wiremix, pipewire-{alsa,pulse}, wireplumber, alsa-utils, networkmanager, iwd, impala, bluez + bluetui, power-profiles-daemon, nautilus, ntfs-3g, os-prober, sddm, sbctl, reflector, nwg-look
- **Styling / fun**: otf-commit-mono-nerd, ttf-jetbrains-mono-nerd, apple_cursor, ghostty, brave-bin, spotify, discord, cava, cmatrix, cbonsai, fastfetch

### Arch on WSL (terminal only)

```bash
chmod +x scripts/wsl.sh
./scripts/wsl.sh
```

The headless subset — CLI toolchain, git/SSH/Oh My Zsh, and only the packages
that make sense without a graphical session: **btop, htop, nvim, tmux, zsh**. It
also switches the default shell to zsh and clones the repo into `~/dotfiles` if
it is not there yet.

Nerd fonts are deliberately *not* installed: under WSL the terminal is a Windows
application and renders with fonts installed on the Windows side, so the
Powerlevel10k glyphs and nvim icons depend on the font configured there.

The script warns and asks for confirmation if `/proc/version` does not look like
WSL, so running it on a bare-metal Arch box by accident is hard.

### Fedora Linux (terminal only)

```bash
chmod +x scripts/install-fedora.sh
./scripts/install-fedora.sh
```

Installs Ghostty from the `scottames/ghostty` COPR plus a small package set,
sets up Oh My Zsh with the same plugin list, then stows **ghostty** and **zsh**
and switches the default shell. Note this script removes an existing
`~/.config/ghostty` and `~/.zshrc` outright rather than backing them up.

### Deploy dotfiles manually

Each top-level directory is a stow package. Deploy everything:

```bash
stow btop ghostty htop hypr nvim rofi swaync tmux waybar wlogout zsh
```

…or one at a time:

```bash
stow nvim       # -> ~/.config/nvim/
stow hypr       # -> ~/.config/hypr/
stow waybar     # -> ~/.config/waybar/
stow tmux       # -> ~/.config/tmux/tmux.conf
stow zsh        # -> ~/.zshrc
```

To remove symlinks:

```bash
stow -D nvim                                                    # one package
stow -D btop ghostty htop hypr nvim rofi swaync tmux waybar wlogout zsh
```

## Repository Structure

Each top-level directory is a **stow package** that mirrors the target path from
`$HOME`:

```
dotfiles/
├── btop/                      # btop system monitor
│   └── .config/btop/
│       ├── btop.conf
│       └── themes/            # catppuccin-{mocha,latte}, rose-pine
├── ghostty/                   # Ghostty terminal emulator
│   └── .config/ghostty/
│       ├── config
│       ├── colors/            # catppuccin-{mocha,latte}.conf
│       └── shaders/           # custom GLSL cursor shaders
├── htop/                      # htop (no theme support — follows the terminal)
│   └── .config/htop/htoprc
├── hypr/                      # Hyprland compositor (Lua config)
│   ├── .config/hypr/
│   │   ├── hyprland.lua       # entry point — requires each module
│   │   ├── hypridle.conf
│   │   ├── hyprlock.conf
│   │   ├── colors.conf        # hyprlang palette switcher line
│   │   ├── colors/            # catppuccin-{mocha,latte}.conf
│   │   ├── modules/           # monitors, bindings, autostart, envs,
│   │   │                      # decorations, animations, layout, misc,
│   │   │                      # input, windowrules, colors
│   │   └── scripts/           # launch, monitor-mode, theme-picker,
│   │                          # wallpaper-picker
│   └── .config/hypr.old/      # the previous hyprlang config, kept for reference
├── nvim/                      # Neovim (LazyVim-based)
│   └── .config/nvim/
│       ├── init.lua
│       ├── lazyvim.json       # enabled LazyVim extras
│       ├── lazy-lock.json
│       └── lua/{config,plugins}/
├── rofi/                      # Rofi launcher
│   └── .config/rofi/
│       ├── config.rasi
│       ├── image-picker.rasi  # thumbnail grid for the wallpaper picker
│       ├── shared/            # colors.rasi (switcher), fonts.rasi
│       └── colors/            # catppuccin-*, everforest, rose-pine
├── swaync/                    # Sway notification center
│   └── .config/swaync/
├── tmux/                      # Tmux (TPM bootstraps itself on first launch)
│   └── .config/tmux/tmux.conf
├── waybar/                    # Waybar status bar
│   └── .config/waybar/
│       ├── config.jsonc
│       ├── style.css
│       ├── colors.css         # switcher line
│       ├── colors/custom/     # catppuccin-*, everforest, rose-pine
│       └── scripts/           # cava, launch, playerinfo, update
├── wlogout/                   # Wlogout menu
│   └── .config/wlogout/
├── zsh/                       # Zsh shell
│   └── .zshrc
├── scripts/                   # Installation and maintenance (not stowed)
│   ├── install.sh             # Arch: full desktop
│   ├── install-fedora.sh      # Fedora: ghostty + zsh
│   ├── wsl.sh                 # Arch on WSL: terminal subset
│   ├── repos.sh               # fzf picker to clone your GitHub repos into ~/dev
│   ├── skills.sh              # install agent skills via `npx skills add`
│   └── theme.sh               # switch the Catppuccin flavour across all configs
├── services/                  # systemd/udev units (not stowed — see below)
└── .php-cs-fixer.dist.php     # PHP-CS-Fixer defaults
```

## Hyprland

The Hyprland config is Lua, not hyprlang. `hyprland.lua` is the entry point and
`require`s each file under `modules/`; the global `hl` table is Hyprland's Lua
API (`hl.bind`, `hl.config`, `hl.monitor`, `hl.window_rule`, …). `.luarc.json`
points lua-ls at `/usr/share/hypr/stubs` so the API autocompletes in Neovim.

`hypr/.config/hypr.old/` is the previous hyprlang config, kept for reference. It
is still part of the `hypr` stow package, so it lands at `~/.config/hypr.old`
and Hyprland ignores it.

### Keybindings

Main modifier is **ALT**.

| Keybind | Action |
| --- | --- |
| `ALT + RETURN` | Ghostty |
| `ALT + E` | Nautilus |
| `ALT + B` | Zen Browser |
| `ALT + SPACE` | Rofi app launcher |
| `ALT + W` | Close window |
| `ALT + T` | Toggle floating |
| `ALT + F` | Fullscreen |
| `ALT + M` | Maximize (internal fullscreen) |
| `ALT + P` | Pseudo-tile |
| `ALT + R` | Restart waybar + swaync, reload Hyprland |
| `ALT + H/J/K/L` | Move focus |
| `ALT + SHIFT + H/J/K/L` | Move window |
| `ALT + CTRL + H/J/K/L` | Move workspace to another monitor |
| `ALT + 1..0` | Switch to workspace 1–10 |
| `ALT + SHIFT + 1..0` | Move window to workspace 1–10 |
| `ALT + scroll` | Cycle workspaces |
| `ALT + LMB / RMB drag` | Move / resize window |
| `ALT + A` | Toggle notification center |
| `ALT + C` | Colour picker (hyprpicker) |
| `ALT + S` | Screenshot the laptop panel |
| `ALT + SHIFT + F12` | Screenshot HDMI-A-1 |
| `ALT + SHIFT + S` | Screenshot a window |
| `ALT + CTRL + S` | Screenshot a region |
| `ALT + SHIFT + V` | Clipboard history (cliphist + rofi) |
| `ALT + SHIFT + BACKSPACE` | Toggle window opacity |
| `ALT + CTRL + W` | Toggle waybar |
| `ALT + SHIFT + W` | Wi-Fi manager (impala) |
| `ALT + CTRL + SPACE` | Wallpaper picker |
| `ALT + SHIFT + SPACE` | Next wallpaper |
| `ALT + CTRL + SHIFT + SPACE` | Rofi flavour picker |
| `ALT + CTRL + T` | Toggle Mocha ⇄ Latte |
| `ALT + CTRL + M` | Toggle mirror ⇄ extend on HDMI-A-1 |
| `ALT + CTRL + DELETE` | Logout menu |

Workspaces 1–5 are bound to `eDP-1`, 6–10 to `HDMI-A-1`. Media, brightness,
caps-lock and num-lock keys route through `swayosd-client` for on-screen
feedback.

### Monitor Modes

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
| hyprland borders | `modules/colors.lua` → `local active` | same file (both flavours inline) |
| tmux | `tmux.conf` → `@catppuccin_flavor` | catppuccin/tmux plugin |
| nvim | `plugins/theme.lua` → `local flavour` | catppuccin/nvim plugin |

`hypr/modules/colors.lua` doubles as the **canonical record of the active
flavour** — `theme.sh`, `theme-picker.sh` and `wallpaper-picker.sh` all read the
`local active = "..."` line out of it.

The GTK apps (waybar, swaync, wlogout) import the raw 26-colour Catppuccin
palette and map it to semantic names in their own `style.css`, so palette files
stay pure colour definitions.

### Wallpapers

`hypr/scripts/wallpaper-picker.sh` reads the same flavour marker and pulls from
`~/Pictures/Wallpapers/catppuccin-<flavour>`, falling back to `catppuccin-mocha`
and then to a plain `catppuccin` directory for flavours with no wallpapers of
their own. Wallpapers are set with `awww`. It has three modes:

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
they launch** — there is no live-reload path for those. GTK3 apps read
`settings.ini` at startup and need a restart too. `htop` has no custom theme
support at all; with `color_scheme=0` it follows the terminal palette, so it
changes with ghostty.

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

### On WSL / Fedora

`theme.sh` degrades gracefully off a Hyprland desktop: it still rewrites every
switcher line in the repo, then warns and skips the parts that need a graphical
session (`gsettings`, the GTK themes, `awww`, waybar/swaync/hyprland reloads).
On WSL that means btop, tmux and nvim follow the flavour as usual.

### Adding a flavour

Add a palette file per app using the existing names, then add the flavour to
`FLAVOURS` in `hypr/scripts/theme-picker.sh` and to the `case` in
`scripts/theme.sh`. Mocha and Latte are complete; the `everforest` and
`rose-pine` files under `btop`, `waybar`, `swaync`, `wlogout` and `rofi` are
older partial leftovers and are not wired into the switcher.

If you add a whole new *directory* to a package (rather than a file inside an
existing one), run `stow -R <package>` so it gets symlinked — ghostty's
`colors/` needed this because `~/.config/ghostty` holds an unmanaged file and so
is not tree-folded.

## Services

System services and daemon configurations live in `services/`. These are **not**
managed by Stow and require manual installation.

### Auto Power Profile

Automatically switches system power profiles based on AC adapter status and
battery capacity using `power-profiles-daemon`.

**What it does:**
- Sets **performance** mode when AC is plugged in
- Sets **power-saver** mode when battery capacity ≤ 30%
- Sets **balanced** mode otherwise
- Runs on system boot and automatically adjusts when power state changes

**How it works:**
- `auto-power-profile.service` — systemd service that runs the script on boot
- `99-auto-power-profile.rules` — udev rules that trigger the script when the AC adapter connects/disconnects
- `auto-power-profile.sh` — shell script that detects power state and sets the profile

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

Edit `services/auto-power-profile.sh` to adjust the capacity thresholds.

**Verification & troubleshooting:**

```bash
systemctl status auto-power-profile.service        # service status
powerprofilesctl get                               # current profile
powerprofilesctl list                              # available profiles
systemctl status power-profiles-daemon.service     # daemon running?
sudo udevadm info --name=/sys/class/power_supply/AC # udev rules loaded?
journalctl -u auto-power-profile.service -n 20     # logs
sudo /usr/local/bin/auto-power-profile.sh          # run it manually
cat /sys/class/power_supply/AC/online              # 1 = plugged in, 0 = unplugged
cat /sys/class/power_supply/BAT0/capacity          # battery percentage
```

## Other Scripts

Neither of these is wired into the install scripts; run them on demand.

| Script | What it does |
| --- | --- |
| `scripts/repos.sh` | Lists your GitHub repos with `gh`, picks with `fzf` (falls back to a numbered menu), and clones the selection into `~/dev`. Prompts to skip / pull / re-clone when a repo is already there. |
| `scripts/skills.sh` | Installs the agent skills used with this setup via `npx skills add`. |

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
- Root-level dotfiles (`.zshrc`) are stored directly inside their package directory
- TPM is **not** installed by the install scripts — `tmux.conf` clones it into `~/.local/share/tmux/plugins/tpm` and installs the plugin list on first launch
- Both Arch scripts assume the repo is at `~/dotfiles`; `wsl.sh` clones it there if missing, `install.sh` does not
- `install.sh` and `wsl.sh` write a hard-coded git `user.name` / `user.email` and generate an SSH key — edit those before running on a machine that is not the author's
- Catppuccin is the consistent theme across all tools; switch flavour with `scripts/theme.sh` (see [Theming](#theming))
- Always review changes before committing updated configurations

### Known warts

- `zsh/.zshrc` sources `/usr/share/nvm/init-nvm.sh` and `~/.local/bin/env` unconditionally. `nvm` comes from the `nvm` package (installed by both Arch scripts); `~/.local/bin/env` comes from the `uv` installer, which no script installs — expect a "no such file" line on first shell start until you install `uv` or drop that line.
- `zsh/.zshrc` hard-codes `/home/itslinx/...` in `PHP_INI_SCAN_DIR` and `/home/mdk0/...` in the Spicetify and flyctl paths. They are inert on other machines but stale.
- `scripts/install.sh` lists `zsh-you-should-use` under its pacman packages, but that package only exists in the AUR — the pacman step fails on it. `wsl.sh` clones the plugin into `$ZSH_CUSTOM` instead, which is what Oh My Zsh actually reads.
- `scripts/install.sh`'s AUR list includes several `*-debug` packages (`paru-debug`, `android-sdk-debug`, …). Those are debug-symbol packages and do not need to be installed explicitly.
