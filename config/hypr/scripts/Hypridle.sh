#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# This is for custom version of waybar idle_inhibitor which activates / deactivates hypridle instead

PROCESS="hypridle"

if [[ "$1" == "status" ]]; then
    sleep 1
    if pgrep -x "$PROCESS" >/dev/null; then
        echo '{"text": " HTB", "class": "htb-off", "tooltip": "HTB Mode OFF (PC will sleep)\nLeft Click: Activate HTB Mode"}'
    else
        echo '{"text": " HTB", "class": "htb-on", "tooltip": "HTB Mode ON (PC will not sleep)\nLeft Click: Deactivate HTB Mode"}'
    fi
elif [[ "$1" == "toggle" ]]; then
    if pgrep -x "$PROCESS" >/dev/null; then
        pkill "$PROCESS"
    else
        "$PROCESS" >/dev/null 2>&1 & disown
    fi
else
    echo "Usage: $0 {status|toggle}"
    exit 1
fi
