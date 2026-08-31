#!/usr/bin/env bash
# cmatrix idle screensaver, driven by hypridle.
#   start : cmatrix in a kitty panel (layer-shell surface, full screen, overlay layer)
#   stop  : kill it via pidfile
# A layer surface, NOT a regular window: in Hyprland >= 0.55 mapping a normal window
# counts as user activity, which instantly resumed hypridle and killed the screensaver
# (and reset the whole idle->lock->suspend chain). Layer surfaces don't touch idle.
# Uses a dedicated config file to bypass wallust color overrides.

PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/screensaver-matrix.pid"

case "$1" in
  start)
    pgrep -x hyprlock >/dev/null && exit 0                 # don't fight the lock
    [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null && exit 0
    kitty +kitten panel --edge=center --layer=overlay \
          --config="$HOME/.config/kitty/screensaver.conf" \
          sh -c 'sleep 0.5 && exec cmatrix -B -a -u 4 -C green' >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
    disown
    ;;
  stop)
    [ -f "$PIDFILE" ] && kill "$(cat "$PIDFILE")" 2>/dev/null
    rm -f "$PIDFILE"
    ;;
esac
exit 0
