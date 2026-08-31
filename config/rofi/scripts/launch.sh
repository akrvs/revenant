#!/bin/bash
# Toggle rofi — close if open, open in requested mode
if pgrep -x rofi > /dev/null; then
    pkill rofi
    exit 0
fi

rofi -show drun -modi "drun,filebrowser"
