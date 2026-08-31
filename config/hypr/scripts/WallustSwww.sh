#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Wallust Colors for current wallpaper

# Get current focused monitor
current_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')

# Get the wallpaper path directly from swww query (Reliable method)
wallpaper_path=$(swww query | grep "$current_monitor" | awk -F 'image: ' '{print $2}')

echo "Monitor: $current_monitor"
echo "Wallpaper: $wallpaper_path"

if [ -n "$wallpaper_path" ]; then
    # symlink the wallpaper to the location Rofi can access
    ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"
    
    # copy the wallpaper for wallpaper effects
    cp -r "$wallpaper_path" "$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

    # execute wallust (Background to prevent hanging)
    echo 'about to execute wallust'
    wallust run "$wallpaper_path" -s &

    # execute matugen for Spicetify/Cava
    # --prefer is required: matugen cannot prompt for a source color when run headless
    matugen image "$wallpaper_path" --prefer saturation &

    # wallpaper-derived colors supersede any fixed omarchy theme
    [ -d "$HOME/.config/omarchy" ] && echo dynamic > "$HOME/.config/omarchy/current-theme"
fi
