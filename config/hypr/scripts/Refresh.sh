#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Scripts for refreshing ags waybar, rofi, swaync, wallust

LOG="/tmp/refresh.log"
echo "Refresh script started at $(date)" > "$LOG"

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserScripts=$HOME/.config/hypr/UserScripts

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Kill already running processes
echo "Killing processes..." >> "$LOG"
pkill -x waybar
pkill -x rofi
pkill -x dunst
#pkill -x ags

# quit ags
#ags -q

sleep 0.5

# Restart waybar
echo "Starting Waybar..." >> "$LOG"
hyprctl dispatch exec waybar >> "$LOG" 2>&1

# relaunch dunst
sleep 0.5
dunst > /dev/null 2>&1 &

# relaunch ags
# ags &

# Relaunching rainbow borders if the script exists
sleep 1
if file_exists "${UserScripts}/RainbowBorders.sh"; then
    ${UserScripts}/RainbowBorders.sh &
fi

echo "Refresh script finished." >> "$LOG"
exit 0
