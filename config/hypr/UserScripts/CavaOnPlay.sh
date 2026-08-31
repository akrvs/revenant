#!/bin/bash
# Slide cava into the WS1 NOC "noc-cava" strip while MUSIC is playing.
# Scoped to music players (ncspot / spotify) so YouTube/Firefox etc. don't trigger it.
# Placement + sizing handled by WindowRules.conf (match ^(noc-cava)$).

PLAYERS="ncspot,spotify"

cava_running() { pgrep -f "kitty --title=noc-cava" > /dev/null; }

launch_cava() {
    cava_running || kitty --title=noc-cava -o font_size=8 cava >/dev/null 2>&1 &
}

kill_cava() {
    cava_running && pkill -f "kitty --title=noc-cava"
}

while true; do
    # follow only the music players; ignore browsers/other audio
    playerctl --player="$PLAYERS" status --follow 2>/dev/null | while IFS= read -r status; do
        case "$status" in
            Playing) launch_cava ;;
            Paused|Stopped) kill_cava ;;
        esac
    done
    # playerctl exited (no music player yet) — clean up and retry
    kill_cava
    sleep 2
done
