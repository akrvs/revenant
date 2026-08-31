#!/bin/bash
# Waybar notification module backed by dunst.
# Shows bell + waiting count, or a DND icon when paused.
# Click = toggle Do-Not-Disturb, right-click = show last, middle = clear all.

command -v dunstctl >/dev/null 2>&1 || { echo '{"text":"","tooltip":"dunst not running","class":"idle"}'; exit 0; }

paused=$(dunstctl is-paused 2>/dev/null)
waiting=$(dunstctl count waiting 2>/dev/null); waiting=${waiting:-0}
history=$(dunstctl count history 2>/dev/null); history=${history:-0}

if [ "$paused" = "true" ]; then
    text="󰂛"
    cls="dnd"
    tip="Do Not Disturb ON\\n${waiting} queued · ${history} in history\\nclick: turn off"
elif [ "$waiting" -gt 0 ]; then
    text="󰂚 ${waiting}"
    cls="unread"
    tip="${waiting} waiting · ${history} in history\\nclick: DND · right: show last · middle: clear"
else
    text="󰂜"
    cls="idle"
    tip="${history} in history\\nclick: DND · right: show last · middle: clear"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tip" "$cls"
