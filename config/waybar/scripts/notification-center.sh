#!/bin/bash
# Minimal notification center for dunst: the notifications + a Clear button.
# Click a notification to dismiss it; click Clear to wipe all. No DND, no filter.

command -v dunstctl >/dev/null 2>&1 || { notify-send "notif-center" "dunst not running"; exit 1; }
command -v jq >/dev/null 2>&1 || { notify-send "notif-center" "jq required"; exit 1; }

while true; do
    mapfile -t rows < <(dunstctl history 2>/dev/null | jq -r '
        .data[0][]? |
        "\(.id.data)\t\(.appname.data // "?"):  \(.summary.data // "")  \((.body.data // "") | gsub("\n";" "))"' 2>/dev/null)

    count=${#rows[@]}
    if [ "$count" -eq 0 ]; then
        menu="    no notifications"
    else
        menu="󰎟  Clear all"
        for r in "${rows[@]}"; do menu+=$'\n'"  ${r#*$'\t'}"; done
    fi

    choice=$(printf '%s' "$menu" | rofi -dmenu -i -no-custom \
             -theme ~/.config/rofi/config-notifications.rasi)

    [ -z "$choice" ] && exit 0

    case "$choice" in
        *"Clear all"*)       dunstctl history-clear; exit 0 ;;
        *"no notifications"*) exit 0 ;;
        *)
            disp="${choice#  }"
            for r in "${rows[@]}"; do
                if [ "${r#*$'\t'}" = "$disp" ]; then
                    dunstctl history-rm "${r%%$'\t'*}" 2>/dev/null
                    break
                fi
            done
            continue
            ;;
    esac
done
