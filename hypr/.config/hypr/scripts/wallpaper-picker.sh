#!/usr/bin/env bash

THEME="catppuccin"

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/$THEME/"

# for custom randomization
# TRANSITIONS=(center grow wipe wave outer)
# AWWW_TRANSITION="${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}"
AWWW_TRANSITION="random"
AWWW_DURATION=2
AWWW_FPS=60

# Cycle wallpaper mode
if [[ "$1" == "--cycle" ]]; then
  files=("$WALLPAPER_DIR"/*)
  INDEX_FILE="$HOME/.cache/wallpaper-index"
  index=$(cat "$INDEX_FILE" 2>/dev/null || echo 0)
  index=$((index % ${#files[@]}))
  awww img "${files[$index]}" \
    --transition-type "$AWWW_TRANSITION" \
    --transition-duration "$AWWW_DURATION" \
    --transition-fps "$AWWW_FPS"
  echo $(((index + 1) % ${#files[@]})) >"$INDEX_FILE"
  exit 0
fi

# Build thumbnail cache
CACHE_DIR="$HOME/.cache/wallpaper-thumbs"
mkdir -p "$CACHE_DIR"
for img in "$WALLPAPER_DIR"/*; do
  name=$(basename "$img")
  thumb="$CACHE_DIR/$name"
  [ -f "$thumb" ] || convert "$img" -thumbnail 200x200^ -gravity center -extent 200x200 "$thumb"
done

# Rofi picker with thumbnails
chosen=$(ls "$WALLPAPER_DIR" | rofi \
  -dmenu \
  -i \
  -p "󰥸" \
  -show-icons \
  -icon-theme "$CACHE_DIR")

# Exit if nothing selected
[ -z "$chosen" ] && exit 0

awww img "$WALLPAPER_DIR/$chosen" \
  --transition-type "$AWWW_TRANSITION" \
  --transition-duration "$AWWW_DURATION" \
  --transition-fps "$AWWW_FPS"
