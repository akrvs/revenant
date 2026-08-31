#!/bin/bash
# Hyprland window switcher via rofi. Lists all open windows across workspaces;
# selecting one focuses it (and its workspace). Replaces the dead AGS overview bind.

command -v jq >/dev/null 2>&1 || { notify-send "WindowSwitcher" "jq not installed"; exit 1; }

# Build "address<TAB>ws  class — title" list
mapfile -t rows < <(hyprctl clients -j | jq -r '
  .[] | select(.mapped == true and .title != "") |
  "\(.address)\t[\(.workspace.id)] \(.class)  —  \(.title)"')

[ ${#rows[@]} -eq 0 ] && { notify-send "WindowSwitcher" "No open windows"; exit 0; }

# Show only the display column in rofi, keep address hidden
choice=$(printf '%s\n' "${rows[@]}" | cut -f2 | \
    rofi -dmenu -i -p "  window" -no-custom \
         -theme-str 'window {width: 45%;} listview {lines: 12;}')

[ -z "$choice" ] && exit 0

# Map the chosen display line back to its address
addr=$(printf '%s\n' "${rows[@]}" | awk -F'\t' -v c="$choice" '$2==c{print $1; exit}')
[ -n "$addr" ] && hyprctl dispatch focuswindow "address:$addr"
