#!/bin/bash
# Waybar weather module. Compact Nerd-Font icon + temp; details in tooltip.
# Uses wttr.in (auto geo-IP location). Caches for 30 min to stay light.

cachefile="$HOME/.cache/waybar-weather.json"
maxage=1800

icon_for() {
    # map wttr condition text -> Nerd Font weather glyph (monochrome, matches hacker look)
    local c; c=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    case "$c" in
        *thunder*|*storm*)              echo "󰖓" ;;
        *snow*|*blizzard*|*sleet*|*ice*) echo "󰖘" ;;
        *rain*|*drizzle*|*shower*)      echo "󰖗" ;;
        *fog*|*mist*|*haze*)            echo "󰖑" ;;
        *overcast*)                     echo "󰖐" ;;
        *cloud*)                        echo "󰖕" ;;
        *clear*|*sunny*)                echo "󰖙" ;;
        *)                              echo "󰖐" ;;
    esac
}

if [ -f "$cachefile" ]; then
    age=$(( $(date +%s) - $(stat -c '%Y' "$cachefile") ))
else
    age=$(( maxage + 1 ))
fi

if [ "$age" -gt "$maxage" ]; then
    raw=$(curl -s --max-time 6 "https://wttr.in/?format=%t|%f|%C|%h|%w|%l" 2>/dev/null)
    if [ -n "$raw" ] && [[ "$raw" != *"Unknown location"* ]] && [[ "$raw" != *"html"* ]]; then
        IFS='|' read -r temp feels desc hum wind loc <<< "$raw"
        temp=$(echo "$temp" | tr -d ' +')
        feels=$(echo "$feels" | tr -d ' +')
        icon=$(icon_for "$desc")
        city=$(echo "$loc" | cut -d, -f1 | sed 's/^ *//;s/ *$//')
        text="${icon} ${city} ${temp}"
        tooltip="${loc}\\n${desc}\\nTemp ${temp}  (feels ${feels})\\nHumidity ${hum}   Wind ${wind}"
        printf '{"text":"%s","tooltip":"%s","class":"weather"}\n' "$text" "$tooltip" > "$cachefile"
    fi
fi

if [ -f "$cachefile" ] && [ -s "$cachefile" ]; then
    cat "$cachefile"
else
    echo '{"text":"","tooltip":"weather unavailable","class":"weather"}'
fi
