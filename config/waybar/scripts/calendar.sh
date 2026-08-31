#!/bin/bash
# Toggle: if already open, close it
if pgrep -f "yad --calendar" > /dev/null; then
    pkill -f "yad --calendar"
    exit 0
fi

# Open calendar (Hyprland window rule positions it below the bar)
yad --calendar --no-buttons --borders=15 --title='WaybarCalendar' --undecorated &
YAD_PID=$!

# Wait for the window to appear and get focus
sleep 0.5

# Watch for focus loss — close calendar when user clicks elsewhere
while kill -0 $YAD_PID 2>/dev/null; do
    sleep 0.2
    active=$(hyprctl activewindow -j 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('title',''))" 2>/dev/null)
    if [ -n "$active" ] && [ "$active" != "WaybarCalendar" ]; then
        kill $YAD_PID 2>/dev/null
        break
    fi
done
