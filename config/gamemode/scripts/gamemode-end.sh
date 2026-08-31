#!/usr/bin/env bash
# gamemode disengaged: restore full desktop config
hyprctl reload >/dev/null 2>&1
dunstify -u low -h string:x-dunst-stack-tag:gamemode "GAMEMODE" "disengaged :: desktop restored" 2>/dev/null
exit 0
