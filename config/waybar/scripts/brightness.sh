#!/bin/bash

# Toggle: close if already open
if pgrep -f "yad.*BrightnessSlider" > /dev/null; then
    pkill -f "yad.*BrightnessSlider"
    exit 0
fi

# Get cursor position
cursor_raw=$(hyprctl cursorpos)
cx=$(echo "$cursor_raw" | cut -d',' -f1 | tr -d ' ')
cy=$(echo "$cursor_raw" | cut -d',' -f2 | tr -d ' ')
x=$((${cx%.*} - 140))
y=$((${cy%.*} + 20))

# Get current brightness using sudo (since user needs re-login for i2c group)
current_bright=$(ddcutil getvcp 10 | grep -oP 'current value =\s*\K\d+')

# FIFO for real-time value passing
FIFO=$(mktemp -u /tmp/bright_XXXXXX)
mkfifo "$FIFO"

# Open slider
yad --scale \
    --min-value=0 \
    --max-value=100 \
    --value="$current_bright" \
    --title="BrightnessSlider" \
    --undecorated \
    --no-buttons \
    --print-partial \
    --step=5 \
    --width=280 \
    --height=50 > "$FIFO" &
YAD_PID=$!

# Wait for window to appear, find it by title, move by address
sleep 0.4
WIN_ADDR=$(hyprctl clients -j | python3 -c "
import sys, json
for c in json.load(sys.stdin):
    if c.get('title') == 'BrightnessSlider':
        print(c.get('address', ''))
        break
")
[ -n "$WIN_ADDR" ] && hyprctl dispatch movewindowpixel "exact $x $y,address:$WIN_ADDR"

# Debounce logic for ddcutil to prevent lagging queue
> /tmp/target_brightness
while IFS= read -r bright; do
    [ -n "$bright" ] && echo "$bright" > /tmp/target_brightness
done < "$FIFO" &

(
    last_bright=""
    while kill -0 $YAD_PID 2>/dev/null; do
        if [ -s /tmp/target_brightness ]; then
            current=$(cat /tmp/target_brightness)
            if [ "$current" != "$last_bright" ]; then
                ddcutil setvcp 10 "$current" --noverify --sleep-multiplier .1
                last_bright="$current"
                pkill -RTMIN+8 waybar # signal waybar to update module
            else
                sleep 0.05
            fi
        else
            sleep 0.05
        fi
    done
) &

# Auto-close
miss_count=0
while kill -0 $YAD_PID 2>/dev/null; do
    sleep 0.3
    active=$(hyprctl activewindow -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('title',''))" 2>/dev/null)
    if [ -n "$active" ] && [ "$active" != "BrightnessSlider" ]; then
        miss_count=$((miss_count + 1))
        [ $miss_count -ge 3 ] && pkill -f "yad.*BrightnessSlider" 2>/dev/null && break
    else
        miss_count=0
    fi
done

rm -f "$FIFO"
