#!/bin/bash
# Launch Stereo Split Cava instances with unique titles

# Kill only existing visualizers
pkill -f "title cava-left-bg"
pkill -f "title cava-right-bg"
pkill -x "cava"

# Launch Left Channel
kitty --title "cava-left-bg" \
      --name "cava-left" \
      -o background_opacity=0 \
      -o window_padding_width=0 \
      -o confirm_os_window_close=0 \
      -e cava -p ~/.config/cava/config_left &

# Launch Right Channel
kitty --title "cava-right-bg" \
      --name "cava-right" \
      -o background_opacity=0 \
      -o window_padding_width=0 \
      -o confirm_os_window_close=0 \
      -e cava -p ~/.config/cava/config_right &
