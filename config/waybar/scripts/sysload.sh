#!/bin/bash
# Waybar system load + uptime module. Shows 1-min load average; full detail in tooltip.

read -r l1 l5 l15 _ < /proc/loadavg
ncpu=$(nproc)

# uptime, pretty
up=$(uptime -p 2>/dev/null | sed 's/^up //')
[ -z "$up" ] && up="?"

# processes
procs=$(awk '{print $4}' /proc/loadavg | cut -d/ -f2)

text="󰾆 ${l1}"
tooltip="Load  ${l1} / ${l5} / ${l15}  (${ncpu} cores)\nUptime  ${up}\nProcs  ${procs}"

printf '{"text":"%s","tooltip":"%s","class":"sysload"}\n' "$text" "$tooltip"
