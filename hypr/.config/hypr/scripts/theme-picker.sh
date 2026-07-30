#!/usr/bin/env bash

# Rofi picker for the Catppuccin flavour. The actual switching lives in
# scripts/theme.sh at the root of the dotfiles repo; this is just a front-end.

SCRIPT_DIR="$(cd -- "$(dirname -- "$(realpath -- "${BASH_SOURCE[0]}")")" && pwd)"

# .../dotfiles/hypr/.config/hypr/scripts -> .../dotfiles
DOTFILES="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"
THEME_SH="$DOTFILES/scripts/theme.sh"

ROFI_THEME="$HOME/.config/rofi/config.rasi"
MARKER="$HOME/.config/hypr/modules/colors.lua"

FLAVOURS=(mocha latte)

if [ ! -x "$THEME_SH" ]; then
  notify-send -u critical "Theme picker" "No executable theme.sh at $THEME_SH"
  exit 1
fi

# Cycle mode, for binding straight to a key without opening the menu
if [[ "$1" == "--toggle" ]]; then
  "$THEME_SH" toggle >/dev/null 2>&1
  exit $?
fi

CURRENT=$(sed -nE 's/^local active = "([a-z]+)".*/\1/p' "$MARKER" 2>/dev/null | head -1)

MENU=""
CURRENT_ROW=""

for i in "${!FLAVOURS[@]}"; do
  flavour="${FLAVOURS[$i]}"
  label="Catppuccin ${flavour^}"
  if [[ "$flavour" == "$CURRENT" ]]; then
    label+="  (current)"
    CURRENT_ROW="$i"
  fi
  MENU+="$label\n"
done

# -format i so the selection maps back to FLAVOURS by index, not by label text
ROFI_ARGS=(-dmenu -i -p "󰔎" -format i -theme "$ROFI_THEME")

# highlight the flavour that is currently set
if [ -n "$CURRENT_ROW" ]; then
  ROFI_ARGS+=(-a "$CURRENT_ROW" -selected-row "$CURRENT_ROW")
fi

chosen=$(echo -en "$MENU" | rofi "${ROFI_ARGS[@]}")

# Exit if nothing selected
[ -z "$chosen" ] && exit 0

flavour="${FLAVOURS[$chosen]}"

if out=$("$THEME_SH" "$flavour" 2>&1); then
  notify-send "Theme" "Switched to Catppuccin ${flavour^}"
else
  notify-send -u critical "Theme" "Failed to switch: $out"
fi
