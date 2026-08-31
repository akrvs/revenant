#!/bin/bash

# Toggle: close if already open
if pgrep -f "yad.*VolumeSlider" > /dev/null; then
    pkill -f "yad.*VolumeSlider"
    exit 0
fi

# Get cursor position
cursor_raw=$(hyprctl cursorpos)
cx=$(echo "$cursor_raw" | cut -d',' -f1 | tr -d ' ')
cy=$(echo "$cursor_raw" | cut -d',' -f2 | tr -d ' ')
x=$((${cx%.*} - 140))
y=$((${cy%.*} + 20))

# Get current volume (0-100)
current_vol=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%')

# FIFO for real-time value passing
FIFO=$(mktemp -u /tmp/vol_XXXXXX)
mkfifo "$FIFO"

# Open slider
yad --scale \
    --min-value=0 \
    --max-value=100 \
    --value="$current_vol" \
    --title="VolumeSlider" \
    --undecorated \
    --no-buttons \
    --print-partial \
    --step=1 \
    --width=280 \
    --height=50 > "$FIFO" &
YAD_PID=$!

# Wait for window to appear, find it by title, move by address
sleep 0.4
WIN_ADDR=$(hyprctl clients -j | python3 -c "
import sys, json
for c in json.load(sys.stdin):
    if c.get('title') == 'VolumeSlider':
        print(c.get('address', ''))
        break
")
[ -n "$WIN_ADDR" ] && hyprctl dispatch movewindowpixel "exact $x $y,address:$WIN_ADDR"

# Read slider values and set volume live
while IFS= read -r vol; do
    [ -n "$vol" ] && pactl set-sink-volume @DEFAULT_SINK@ "${vol}%"
done < "$FIFO" &

# Auto-close — require 3 consecutive checks of non-VolumeSlider focus
# to avoid closing during drag interactions
miss_count=0
while kill -0 $YAD_PID 2>/dev/null; do
    sleep 0.3
    active=$(hyprctl activewindow -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('title',''))" 2>/dev/null)
    if [ -n "$active" ] && [ "$active" != "VolumeSlider" ]; then
        miss_count=$((miss_count + 1))
        [ $miss_count -ge 3 ] && pkill -f "yad.*VolumeSlider" 2>/dev/null && break
    else
        miss_count=0
    fi
done

rm -f "$FIFO"
