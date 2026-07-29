#!/usr/bin/env bash

THEME="catppuccin"

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/$THEME"
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

# Cycle wallpaper mode
if [[ "$1" == "--cycle" ]]; then
  index=$(cat "$INDEX_FILE" 2>/dev/null || echo 0)
  index=$((index % ${#WALLPAPERS[@]}))
  set_wallpaper "${WALLPAPERS[$index]}"
  echo $(((index + 1) % ${#WALLPAPERS[@]})) >"$INDEX_FILE"
  exit 0
fi

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
