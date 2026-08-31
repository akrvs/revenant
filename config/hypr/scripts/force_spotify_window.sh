#!/bin/bash

# Loop to wait for Spotify to appear and force it into the desired state
while true; do
  if hyprctl clients -j | jq -e '.[] | select(.class == "spotify")' > /dev/null; then
    # Force fullscreen off, set floating, and force the specific dimensions
    hyprctl dispatch fullscreen 0, class:spotify
    hyprctl dispatch togglefloating, class:spotify
    hyprctl dispatch resizewindow exact 1240 900, class:spotify
    hyprctl dispatch movewindowpixel exact 1300 60, class:spotify
    break
  fi
  sleep 0.5
done
