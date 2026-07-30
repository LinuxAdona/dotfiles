#!/usr/bin/env bash
#
# Switch the Catppuccin flavour across every config in this repo.
#
# Each config keeps a single "switcher" line that points at a flavour-specific
# palette file; this script rewrites those lines in place. Because ~/.config is
# stowed into this repo, editing here is what the running apps actually see.
#
#   ./scripts/theme.sh            # show what each config is set to
#   ./scripts/theme.sh latte      # switch everything to Catppuccin Latte
#   ./scripts/theme.sh toggle     # flip between mocha and latte

set -euo pipefail

DOTFILES="$(cd -- "$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")/.." && pwd)"

# Canonical record of the active flavour.
MARKER="hypr/.config/hypr/modules/colors.lua"

# Latte drives the system into light mode, Mocha into dark. Change these if you
# install a different light/dark GTK theme pair under ~/.themes.
GTK_THEME_LIGHT="Catppuccin-BL-MB-Light"
GTK_THEME_DARK="Catppuccin-BL-MB-Dark"

# label | repo-relative file | ERE matching the switcher line | replacement
# @f@ expands to the flavour (mocha), @F@ to its capitalised form (Mocha).
targets() {
	cat <<-'EOF'
		btop|btop/.config/btop/btop.conf|^color_theme *=|color_theme = "catppuccin-@f@"
		ghostty|ghostty/.config/ghostty/config|^config-file *=.*catppuccin|config-file = colors/catppuccin-@f@.conf
		waybar|waybar/.config/waybar/colors.css|^@import .*catppuccin|@import './colors/custom/catppuccin-@f@.css';
		swaync|swaync/.config/swaync/colors.css|^@import .*catppuccin|@import './colors/catppuccin-@f@.css';
		wlogout|wlogout/.config/wlogout/colors.css|^@import .*catppuccin|@import './colors/catppuccin-@f@.css';
		rofi|rofi/.config/rofi/shared/colors.rasi|^@import .*catppuccin|@import "~/.config/rofi/colors/catppuccin-@f@.rasi"
		hypr|hypr/.config/hypr/colors.conf|^source *=.*catppuccin|source = ~/.config/hypr/colors/catppuccin-@f@.conf
		hypr-lua|hypr/.config/hypr/modules/colors.lua|^local active *=|local active = "@f@"
		tmux|tmux/.config/tmux/tmux.conf|^set -g @catppuccin_flavor|set -g @catppuccin_flavor '@f@'
		nvim|nvim/.config/nvim/lua/plugins/theme.lua|^local flavour *=|local flavour = "@f@"
	EOF
}

if [[ -t 1 ]]; then
	BOLD=$'\033[1m' DIM=$'\033[2m' GREEN=$'\033[32m' YELLOW=$'\033[33m' RED=$'\033[31m' RESET=$'\033[0m'
else
	BOLD='' DIM='' GREEN='' YELLOW='' RED='' RESET=''
fi

info() { printf '  %s\n' "$*"; }
ok() { printf '  %s✓%s %-9s %s%s%s\n' "$GREEN" "$RESET" "$1" "$DIM" "$2" "$RESET"; }
warn() { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*" >&2; }
die() {
	printf '%serror:%s %s\n' "$RED" "$RESET" "$*" >&2
	exit 1
}

usage() {
	cat <<EOF
${BOLD}Usage:${RESET} ${0##*/} [FLAVOUR]

Switch every config in this dotfiles repo to a Catppuccin flavour.

${BOLD}Flavours:${RESET}
  mocha, dark     Catppuccin Mocha
  latte, light    Catppuccin Latte
  toggle          flip between the two

With no argument, prints the flavour each config currently points at.
EOF
}

# Replace whole lines matching an ERE. Line-oriented, so the replacement text
# needs no escaping. Returns non-zero if nothing matched.
replace_line() {
	local file=$1 regex=$2 newline=$3
	local tmp line found=0

	tmp=$(mktemp)
	while IFS= read -r line || [[ -n $line ]]; do
		if [[ $line =~ $regex ]]; then
			printf '%s\n' "$newline"
			found=1
		else
			printf '%s\n' "$line"
		fi
	done <"$file" >"$tmp"

	if ((found)); then
		# Preserve the original mode rather than mktemp's 0600.
		chmod --reference="$file" "$tmp" 2>/dev/null || true
		mv -- "$tmp" "$file"
		return 0
	fi

	rm -f -- "$tmp"
	return 1
}

current_flavour() {
	local path="$DOTFILES/$MARKER"
	[[ -f $path ]] || return 1
	sed -nE 's/^local active = "([a-z]+)".*/\1/p' "$path" | head -1
}

show_current() {
	printf '%sActive flavour:%s %s\n\n' "$BOLD" "$RESET" "$(current_flavour || echo unknown)"
	printf '%sSwitcher lines:%s\n' "$BOLD" "$RESET"

	local label rel regex tmpl line
	while IFS='|' read -r label rel regex tmpl; do
		[[ -n ${label:-} ]] || continue
		if [[ ! -f "$DOTFILES/$rel" ]]; then
			warn "$(printf '%-9s' "$label") $rel not found"
			continue
		fi
		line=$(grep -m1 -E "$regex" "$DOTFILES/$rel" || true)
		if [[ -n $line ]]; then
			printf '  %-9s %s\n' "$label" "$line"
		else
			warn "$(printf '%-9s' "$label") no switcher line in $rel"
		fi
	done < <(targets)
}

# Replace "key=value" in an ini file, appending under [Settings] if absent.
set_ini_key() {
	local file=$1 key=$2 value=$3
	local tmp line found=0

	[[ -f $file ]] || return 1

	tmp=$(mktemp)
	while IFS= read -r line || [[ -n $line ]]; do
		if [[ $line == "$key="* ]]; then
			printf '%s=%s\n' "$key" "$value"
			found=1
		else
			printf '%s\n' "$line"
		fi
	done <"$file" >"$tmp"

	if ((!found)); then
		awk -v k="$key" -v v="$value" '
			{ print }
			/^\[Settings\]/ && !seen { print k "=" v; seen = 1 }
		' "$file" >"$tmp"
	fi

	chmod --reference="$file" "$tmp" 2>/dev/null || true
	mv -- "$tmp" "$file"
}

# The "-BL-MB-" themes reach GTK4 apps through symlinks into ~/.themes.
relink_gtk4_theme() {
	local gtk_theme=$1 name link target
	for name in assets gtk.css gtk-dark.css; do
		link="$HOME/.config/gtk-4.0/$name"
		# only re-point links that are already symlinks; never clobber real files
		[[ -L $link ]] || continue
		target="$HOME/.themes/$gtk_theme/gtk-4.0/$name"
		[[ -e $target ]] || continue
		ln -sfn "$target" "$link"
		ok "gtk4:$name" "-> ~/.themes/$gtk_theme/gtk-4.0/$name"
	done
}

# Latte -> light mode, Mocha -> dark mode, for GTK/libadwaita apps and the
# xdg-desktop-portal appearance setting that Electron/Chromium apps read.
apply_system_appearance() {
	local flavour=$1
	local scheme gtk_theme prefer_dark

	if [[ $flavour == latte ]]; then
		scheme=prefer-light
		gtk_theme=$GTK_THEME_LIGHT
		prefer_dark=0
	else
		scheme=prefer-dark
		gtk_theme=$GTK_THEME_DARK
		prefer_dark=1
	fi

	printf '\n%sSystem appearance:%s\n' "$BOLD" "$RESET"

	if [[ ! -d "$HOME/.themes/$gtk_theme" && ! -d "/usr/share/themes/$gtk_theme" ]]; then
		warn "GTK theme '$gtk_theme' is not installed — leaving the GTK theme alone"
		gtk_theme=''
	fi

	# Files first, dconf last. Running apps watch the dconf keys and re-read
	# their theme the moment those change, so the CSS and settings.ini they
	# would read must already be correct — otherwise a fast-reacting app picks
	# up the previous theme.

	# GTK apps that read settings.ini rather than dconf. These files are not
	# stowed, so they are edited in place in ~/.config.
	local ini
	for ini in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
		[[ -f $ini ]] || continue
		[[ -n $gtk_theme ]] && set_ini_key "$ini" gtk-theme-name "$gtk_theme"
		set_ini_key "$ini" gtk-application-prefer-dark-theme "$prefer_dark"
		ok "${ini#"$HOME/.config/"}" "prefer-dark=$prefer_dark${gtk_theme:+, $gtk_theme}"
	done

	[[ -n $gtk_theme ]] && relink_gtk4_theme "$gtk_theme"

	if command -v gsettings >/dev/null 2>&1; then
		if [[ -n $gtk_theme ]]; then
			gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"
			ok gtk-theme "$gtk_theme"
		fi
		# Last: this is the key xdg-desktop-portal exposes, so it is what most
		# apps actually react to.
		gsettings set org.gnome.desktop.interface color-scheme "$scheme"
		ok color-scheme "$scheme"
	else
		warn "gsettings not found — skipped the dconf appearance settings"
	fi

	return 0
}

# Point the wallpaper at the new flavour's set. The picker owns the directory
# resolution and only swaps when the current wallpaper is from the wrong set.
apply_wallpaper() {
	local picker="$HOME/.config/hypr/scripts/wallpaper-picker.sh" result

	printf '\n%sWallpaper:%s\n' "$BOLD" "$RESET"

	if [[ ! -x $picker ]]; then
		warn "wallpaper-picker.sh not found — wallpaper unchanged"
		return 0
	fi

	# awww only runs inside a graphical session
	if ! pgrep -x awww-daemon >/dev/null 2>&1; then
		info "${DIM}awww-daemon not running — wallpaper unchanged${RESET}"
		return 0
	fi

	if result=$("$picker" --sync 2>/dev/null); then
		ok "${result%% *}" "${result#* }"
	else
		warn "wallpaper-picker.sh --sync failed — wallpaper unchanged"
	fi

	return 0
}

reload_running_apps() {
	printf '\n%sReloading:%s\n' "$BOLD" "$RESET"
	local any=0

	if pgrep -x waybar >/dev/null 2>&1 && pkill -USR2 -x waybar; then
		ok waybar "config + css reloaded"
		any=1
	fi

	if pgrep -x swaync >/dev/null 2>&1 && command -v swaync-client >/dev/null 2>&1 &&
		swaync-client --reload-css >/dev/null 2>&1; then
		swaync-client --reload-config >/dev/null 2>&1 || true
		ok swaync "css reloaded"
		any=1
	fi

	if command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1; then
		ok hyprland "window borders reloaded"
		any=1
	fi

	# Ghostty does not watch its config file, but it exports the same
	# reload-config action its menu uses on the session bus.
	if pgrep -x ghostty >/dev/null 2>&1 && command -v gdbus >/dev/null 2>&1 &&
		gdbus call --session --dest com.mitchellh.ghostty \
			--object-path /com/mitchellh/ghostty \
			--method org.gtk.Actions.Activate \
			reload-config "[]" "{}" >/dev/null 2>&1; then
		ok ghostty "config reloaded"
		any=1
	fi

	if command -v tmux >/dev/null 2>&1 && tmux has-session >/dev/null 2>&1 &&
		tmux source-file "$HOME/.config/tmux/tmux.conf" >/dev/null 2>&1; then
		ok tmux "status bar reloaded"
		any=1
	fi

	((any)) || info "${DIM}nothing running to reload${RESET}"

	printf '\n%sApplies on next launch:%s\n' "$BOLD" "$RESET"
	info "${DIM}btop, rofi, wlogout, hyprlock, nvim${RESET}"
	info "${DIM}GTK3 apps read settings.ini at startup, so they need a restart${RESET}"
	info "${DIM}htop has no custom themes — it follows the terminal palette${RESET}"
}

main() {
	local arg=${1:-}

	case $arg in
	'')
		show_current
		exit 0
		;;
	-h | --help | help)
		usage
		exit 0
		;;
	esac

	local flavour
	case $arg in
	mocha | dark) flavour=mocha ;;
	latte | light) flavour=latte ;;
	toggle)
		if [[ $(current_flavour || echo mocha) == latte ]]; then
			flavour=mocha
		else
			flavour=latte
		fi
		;;
	*)
		usage >&2
		die "unknown flavour: $arg"
		;;
	esac

	# "mocha" -> "Mocha", for ghostty's builtin theme names.
	local Flavour=${flavour^}

	printf '%sSwitching to Catppuccin %s%s\n\n' "$BOLD" "$Flavour" "$RESET"

	local label rel regex tmpl newline
	while IFS='|' read -r label rel regex tmpl; do
		[[ -n ${label:-} ]] || continue

		newline=${tmpl//@f@/$flavour}
		newline=${newline//@F@/$Flavour}

		if [[ ! -f "$DOTFILES/$rel" ]]; then
			warn "$(printf '%-9s' "$label") $rel not found — skipped"
		elif replace_line "$DOTFILES/$rel" "$regex" "$newline"; then
			ok "$label" "$newline"
		else
			warn "$(printf '%-9s' "$label") no line matching /$regex/ in $rel — left alone"
		fi
	done < <(targets)

	apply_system_appearance "$flavour"
	apply_wallpaper
	reload_running_apps
}

main "$@"
