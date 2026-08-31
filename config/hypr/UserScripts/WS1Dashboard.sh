#!/usr/bin/env bash
# WS1 "NOC" dashboard — a wall of TUI panels on workspace 1.
# Panels are placed by title via WindowRules.conf (match ^(noc-*)$).
# cava is NOT launched here; CavaOnPlay.sh slides it into the noc-cava slot on playback.

GH() { ghostty "$@" >/dev/null 2>&1 & }

launch() {
  local title=$1 fs=$2; shift 2
  # already up? skip
  hyprctl clients -j | grep -q "\"title\": \"$title\"" && return
  GH --title="$title" --font-size="$fs" -e "$@"
}

launch "noc-btop"    9  btop
launch "noc-gpu"     9  amdgpu_top
launch "noc-music"   10 ncspot
