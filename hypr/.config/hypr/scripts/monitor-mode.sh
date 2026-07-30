#!/usr/bin/env bash

# Toggle modules/monitors.lua between mirroring the laptop panel onto HDMI-A-1
# and extending onto it, then reload Hyprland. The choice is written back to the
# config so it survives a restart.
#
#   monitor-mode.sh            toggle
#   monitor-mode.sh mirror     duplicate the laptop panel
#   monitor-mode.sh extend     extend to the right of the laptop panel

set -euo pipefail

# Resolve through the stow symlink to the real file in the dotfiles repo, so the
# edit lands in git rather than replacing a symlink.
SELF="$(realpath -- "${BASH_SOURCE[0]}")"
MONITORS="$(dirname -- "$SELF")/../modules/monitors.lua"

if [ ! -f "$MONITORS" ]; then
  notify-send -u critical "Monitor mode" "monitors.lua not found at $MONITORS"
  exit 1
fi

current=$(sed -nE 's/^local mode = "([a-z]+)".*/\1/p' "$MONITORS" | head -1)

case "${1:-toggle}" in
mirror | duplicate) target="mirror" ;;
extend | extended) target="extend" ;;
toggle)
  if [ "$current" = "mirror" ]; then target="extend"; else target="mirror"; fi
  ;;
*)
  echo "usage: ${0##*/} [mirror|extend|toggle]" >&2
  exit 1
  ;;
esac

# Line-oriented replacement, so the file's other contents are untouched
tmp=$(mktemp)
found=0
while IFS= read -r line || [ -n "$line" ]; do
  if [[ $line =~ ^local\ mode\ *= ]]; then
    printf 'local mode = "%s"\n' "$target"
    found=1
  else
    printf '%s\n' "$line"
  fi
done <"$MONITORS" >"$tmp"

if [ "$found" -eq 0 ]; then
  rm -f "$tmp"
  notify-send -u critical "Monitor mode" "No 'local mode = ...' line in monitors.lua"
  exit 1
fi

chmod --reference="$MONITORS" "$tmp" 2>/dev/null || true
mv -- "$tmp" "$MONITORS"

hyprctl reload >/dev/null 2>&1

if [ "$target" = "mirror" ]; then
  notify-send "Monitor mode" "Mirroring to HDMI-A-1"
else
  notify-send "Monitor mode" "Extended onto HDMI-A-1"
fi
