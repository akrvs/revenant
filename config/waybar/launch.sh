#!/bin/bash 

killall -9 waybar 2>/dev/null
waybar &
disown
