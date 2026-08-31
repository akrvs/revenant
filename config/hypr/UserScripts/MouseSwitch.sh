#!/bin/bash
# Cycle next
hyprctl dispatch cyclenext

# Get new window geometry
active=$(hyprctl activewindow -j)
x=$(echo "$active" | jq '.at[0]')
y=$(echo "$active" | jq '.at[1]')
w=$(echo "$active" | jq '.size[0]')
h=$(echo "$active" | jq '.size[1]')

# Calculate center
cx=$((x + w / 2))
cy=$((y + h / 2))

# Move mouse to center (ydotool)
ydotool mousemove --absolute $cx $cy
