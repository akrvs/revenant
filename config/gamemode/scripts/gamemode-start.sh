#!/usr/bin/env bash
# gamemode engaged: strip compositor eye-candy for max frames
hyprctl --batch "keyword animations:enabled 0; keyword decoration:blur:enabled 0; keyword decoration:shadow:enabled 0" >/dev/null 2>&1
dunstify -u low -h string:x-dunst-stack-tag:gamemode "GAMEMODE" "engaged :: renice + gpu high + fx off" 2>/dev/null
exit 0
