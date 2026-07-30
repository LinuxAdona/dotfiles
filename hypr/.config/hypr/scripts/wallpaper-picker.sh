#!/usr/bin/env bash

# Follow whichever flavour scripts/theme.sh last set, so switching theme also
# switches the wallpaper set. Falls back to the mocha set, then to an unsuffixed
# "catppuccin" directory, for flavours with no wallpapers of their own.
FLAVOUR_MARKER="$HOME/.config/hypr/modules/colors.lua"
FLAVOUR=$(sed -nE 's/^local active = "([a-z]+)".*/\1/p' "$FLAVOUR_MARKER" 2>/dev/null | head -1)

WALLPAPER_ROOT="$HOME/Pictures/Wallpapers"

for candidate in "catppuccin-$FLAVOUR" "catppuccin-mocha" "catppuccin"; do
  if [ -d "$WALLPAPER_ROOT/$candidate" ]; then
    THEME="$candidate"
    break
  fi
done

WALLPAPER_DIR="$WALLPAPER_ROOT/${THEME:-catppuccin-mocha}"
ROFI_THEME="$HOME/.config/rofi/image-picker.rasi"
INDEX_FILE="$HOME/.cache/wallpaper-index"

# for custom randomization
# TRANSITIONS=(center grow wipe wave outer)
# AWWW_TRANSITION="${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}"
AWWW_TRANSITION="random"
AWWW_DURATION=2
AWWW_FPS=60

set_wallpaper() {
  awww img "$1" \
    --transition-type "$AWWW_TRANSITION" \
    --transition-duration "$AWWW_DURATION" \
    --transition-fps "$AWWW_FPS"
}

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
  notify-send "Wallpaper picker" "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

# Advance to the next wallpaper in the current set. Prints the path it set on
# stdout; awww's own output goes to stderr so callers can capture just the path.
cycle_wallpaper() {
  local index
  index=$(cat "$INDEX_FILE" 2>/dev/null || echo 0)
  index=$((index % ${#WALLPAPERS[@]}))
  set_wallpaper "${WALLPAPERS[$index]}" >&2
  echo $(((index + 1) % ${#WALLPAPERS[@]})) >"$INDEX_FILE"
  printf '%s\n' "${WALLPAPERS[$index]}"
}

case "$1" in
# Cycle wallpaper mode
--cycle)
  cycle_wallpaper >/dev/null
  exit 0
  ;;
# Make the wallpaper match the active flavour, used by scripts/theme.sh. Only
# changes it when the current one is not already from this flavour's directory,
# so re-running a theme switch does not churn the wallpaper.
--sync)
  CURRENT=$(awww query 2>/dev/null | head -1 | awk '{print $NF}')
  if [[ "$CURRENT" == "$WALLPAPER_DIR"/* ]]; then
    printf 'kept %s\n' "$CURRENT"
  else
    printf 'set %s\n' "$(cycle_wallpaper)"
  fi
  exit 0
  ;;
esac

# Rofi picker with thumbnails
CURRENT=$(awww query 2>/dev/null | head -1 | awk '{print $NF}')
MENU=""
CURRENT_ROW=""

for i in "${!WALLPAPERS[@]}"; do
  path="${WALLPAPERS[$i]}"
  MENU+="$(basename "$path")\0icon\x1f${path}\n"
  [[ "$path" == "$CURRENT" ]] && CURRENT_ROW="$i"
done

ROFI_ARGS=(-dmenu -i -p "󰥸" -theme "$ROFI_THEME")

# highlight the wallpaper that is currently set
if [ -n "$CURRENT_ROW" ]; then
  ROFI_ARGS+=(-a "$CURRENT_ROW" -selected-row "$CURRENT_ROW")
fi

chosen=$(echo -en "$MENU" | rofi "${ROFI_ARGS[@]}")

# Exit if nothing selected
[ -z "$chosen" ] && exit 0

set_wallpaper "$WALLPAPER_DIR/$chosen"
