#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for Random Wallpaper ( CTRL ALT W)

wallDIR="$HOME/Pictures/wallpapers"
scriptsDir="$HOME/.config/hypr/scripts"

focused_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

# Find all wallpapers and sort them alphabetically
PICS=($(find "${wallDIR}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" \) | sort))

if [ ${#PICS[@]} -eq 0 ]; then
    echo "No wallpapers found in ${wallDIR}"
    exit 1
fi

# Get current wallpaper path to determine the next one
current_wallpaper=$(swww query | grep "$focused_monitor" | awk -F 'image: ' '{print $2}')

if [ -z "$current_wallpaper" ]; then
    current_wallpaper=$(swww query | awk -F 'image: ' '{print $2}' | head -n 1)
fi

if [ -z "$current_wallpaper" ]; then
    current_wallpaper=$(readlink -f "$HOME/.config/rofi/.current_wallpaper")
fi

# Find the index of the current wallpaper
current_index=-1
for i in "${!PICS[@]}"; do
    if [[ "${PICS[$i]}" == "$current_wallpaper" ]]; then
        current_index=$i
        break
    fi
done

# Cycle to the next wallpaper, wrapping around if at the end
if [ $current_index -eq -1 ]; then
    next_index=0
else
    next_index=$(( (current_index + 1) % ${#PICS[@]} ))
fi

NEXTPIC="${PICS[$next_index]}"

# Transition config
FPS=60
TYPE="random"
DURATION=1
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"

swww query || swww-daemon --format xrgb && swww img -o $focused_monitor "${NEXTPIC}" $SWWW_PARAMS

${scriptsDir}/WallustSwww.sh
sleep 1
${scriptsDir}/Refresh.sh
sleep 0.2
${scriptsDir}/walogram.sh
