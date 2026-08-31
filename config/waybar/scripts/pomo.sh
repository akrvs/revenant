#!/bin/bash

if [ "$1" = "--start" ]; then
    result=$(yad --form \
        --title="Pomo" \
        --button="Start:0" \
        --button="Cancel:1" \
        --field="Title:" "" \
        --field="Duration:" "25m" \
        --width=280)
    [ $? -ne 0 ] && exit 0

    title=$(echo "$result" | cut -d'|' -f1)
    duration=$(echo "$result" | cut -d'|' -f2)
    [ -z "$title" ] && exit 0

    kitty --title "pomo" -- pomo start -d "$duration" -p 1 "$title" &
else
    echo "󱎫 $(pomo status 2>/dev/null)"
fi
