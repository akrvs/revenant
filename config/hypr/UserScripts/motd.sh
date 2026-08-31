#!/usr/bin/env bash
# Per-terminal MOTD — compact hacker readout. Sourced from ~/.zshrc on interactive start.
# Fast only: no network, no heavy forks.

# neon palette
g=$'\e[38;5;46m'   # green
c=$'\e[38;5;51m'   # cyan
m=$'\e[38;5;201m'  # magenta
d=$'\e[38;5;240m'  # dim
y=$'\e[38;5;220m'  # amber
r=$'\e[0m'; b=$'\e[1m'

host=$(hostname)
kern=$(uname -r)
up=$(uptime -p 2>/dev/null | sed 's/^up //')
load=$(cut -d' ' -f1 /proc/loadavg)
pkgs=$(pacman -Qq 2>/dev/null | wc -l)

# memory (from /proc, no forks)
read -r _ memtot _ < <(grep -m1 MemTotal /proc/meminfo)
read -r _ memav  _ < <(grep -m1 MemAvailable /proc/meminfo)
memused=$(( (memtot - memav) / 1024 ))
memtotm=$(( memtot / 1024 ))
mempct=$(( (memtot - memav) * 100 / memtot ))

# root disk usage
read -r dused dtot dpct < <(df -h --output=used,size,pcent / 2>/dev/null | tail -1)

# gamified "threat level" from 15-min load (just for flavor)
l15=$(cut -d' ' -f3 /proc/loadavg | cut -d. -f1)
if   [ "${l15:-0}" -ge 4 ]; then threat="${r}${y}ELEVATED${r}"
elif [ "${l15:-0}" -ge 1 ]; then threat="${r}${c}GUARDED${r}"
else threat="${r}${g}NOMINAL${r}"; fi

# tiny bar for mem
bar() { local p=$1 n=$((p/10)) i s=""; for ((i=0;i<10;i++)); do [ $i -lt $n ] && s+="█" || s+="░"; done; printf '%s' "$s"; }

printf '\n'
printf "  ${g}${b}▓▒░${r} ${c}${b}%s${r}${d}@arch-station${r}  ${d}·${r}  ${d}sys status:${r} %s\n" "$USER" "$threat"
printf "  ${d}├─${r} ${g}kernel${r}  %s   ${d}·${r}   ${g}up${r} %s\n" "$kern" "${up:-unknown}"
printf "  ${d}├─${r} ${g}pkgs${r}    ${m}%s${r}   ${d}·${r}   ${g}load${r} %s\n" "$pkgs" "$load"
printf "  ${d}├─${r} ${g}mem${r}     ${c}%s${r} ${d}%s%%${r}  %sM/%sM\n" "$(bar $mempct)" "$mempct" "$memused" "$memtotm"
printf "  ${d}╰─${r} ${g}disk /${r}  ${y}%s${r} used of %s ${d}(%s)${r}\n" "$dused" "$dtot" "$dpct"
printf '\n'
