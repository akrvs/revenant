#!/bin/bash
# Shows CPU temperature from lm_sensors

temp=$(sensors 2>/dev/null | grep 'Tctl' | awk '{print $2}' | tr -d '+°C' | cut -d'.' -f1)

if [ -n "$temp" ]; then
    echo "${temp}°C"
else
    echo "N/A"
fi
