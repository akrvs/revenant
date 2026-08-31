#!/bin/bash
# Get total usage for Root and Games drive

# Get the last line (Total)
line=$(df -h --total / /home/akrvs/Games | tail -1)

# Extract fields (Size=2, Used=3, Use%=5)
total=$(echo "$line" | awk '{print $2}')
used=$(echo "$line" | awk '{print $3}')
pcent=$(echo "$line" | awk '{print $5}')

# JSON Output
printf '{"text": "󰉉 %s", "tooltip": "Total System Storage\\nUsed: %s / %s"}\n' "$pcent" "$used" "$total"
