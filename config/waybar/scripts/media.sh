#!/bin/bash
# Shows current Spotify track in waybar

status=$(playerctl --player spotify status 2>/dev/null)

if [ "$status" = "Playing" ] || [ "$status" = "Paused" ]; then
    # Use sed to truncate by character, not byte
    artist=$(playerctl --player spotify metadata artist 2>/dev/null)
    title=$(playerctl --player spotify metadata title 2>/dev/null)

    # Truncate if longer than 18/22 characters, adding '...' only if needed
    artist_truncated=$(echo "$artist" | sed 's/^\(.\{18\}\).\{1,\}$/\1.../')
    title_truncated=$(echo "$title" | sed 's/^\(.\{22\}\).\{1,\}$/\1.../')

    if [ -n "$artist" ]; then
        display_text="  $artist_truncated - $title_truncated"
    else
        display_text="  $title_truncated"
    fi

    if [ "$status" = "Paused" ]; then
        echo "{\"text\": \"$display_text\", \"class\": \"paused\", \"tooltip\": \"Click to resume\"}"
    else
        echo "{\"text\": \"$display_text\", \"class\": \"playing\", \"tooltip\": \"Click to pause\"}"
    fi
else
    echo "{\"text\": \"\", \"class\": \"stopped\"}"
fi
