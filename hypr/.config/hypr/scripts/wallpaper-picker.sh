#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# for custom randomization
# TRANSITIONS=(fade grow wipe wave outer)
# AWWW_TRANSITION="${TRANSITIONS[$RANDOM % ${#TRANSITIONS[@]}]}"

AWWW_TRANSITION="any"
AWWW_DURATION=1
AWWW_FPS=60

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
  -p "Wallpaper" \
  -show-icons \
  -icon-theme "$CACHE_DIR")

# Exit if nothing selected
[ -z "$chosen" ] && exit 0

awww img "$WALLPAPER_DIR/$chosen" \
  --transition-type "$AWWW_TRANSITION" \
  --transition-duration "$AWWW_DURATION" \
  --transition-fps "$AWWW_FPS"
