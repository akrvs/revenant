#!/bin/bash
# Subtle notification sound for dunst.
# dunst calls: script <appname> <summary> <body> <icon> <urgency>
# We use $5 (urgency: LOW|NORMAL|CRITICAL). LOW makes no sound.

urgency="$5"
snd_dir="/usr/share/sounds/freedesktop/stereo"

case "$urgency" in
    CRITICAL) file="$snd_dir/bell.oga";                vol=28000 ;;
    NORMAL)   file="$snd_dir/message-new-instant.oga"; vol=16000 ;;
    *)        exit 0 ;;
esac

[ -f "$file" ] || file="$snd_dir/message.oga"
[ -f "$file" ] && paplay --volume="$vol" "$file" >/dev/null 2>&1 &
exit 0
