#!/bin/bash
# Waybar GPU module for AMD (amdgpu). Outputs JSON: usage% + temp, VRAM in tooltip.
# Auto-detects the render card (works even if card index / hwmon index changes).

card=""
for c in /sys/class/drm/card*/device; do
    if [ -e "$c/gpu_busy_percent" ] && [ "$(cat "$c/vendor" 2>/dev/null)" = "0x1002" ]; then
        card="$c"; break
    fi
done

if [ -z "$card" ]; then
    echo '{"text":"󰢮 n/a","tooltip":"No AMD GPU found"}'
    exit 0
fi

usage=$(cat "$card/gpu_busy_percent" 2>/dev/null)
usage=${usage:-0}

# Temperature (edge) from hwmon
temp_c=0
hw=$(ls -d "$card"/hwmon/hwmon* 2>/dev/null | head -1)
if [ -n "$hw" ] && [ -e "$hw/temp1_input" ]; then
    temp_raw=$(cat "$hw/temp1_input" 2>/dev/null)
    temp_c=$(( temp_raw / 1000 ))
fi

# VRAM
vram_used=$(cat "$card/mem_info_vram_used" 2>/dev/null)
vram_total=$(cat "$card/mem_info_vram_total" 2>/dev/null)
vram_used_gb="?"; vram_total_gb="?"; vram_pct="?"
if [ -n "$vram_used" ] && [ -n "$vram_total" ] && [ "$vram_total" -gt 0 ]; then
    vram_used_gb=$(awk "BEGIN{printf \"%.1f\", $vram_used/1073741824}")
    vram_total_gb=$(awk "BEGIN{printf \"%.1f\", $vram_total/1073741824}")
    vram_pct=$(( vram_used * 100 / vram_total ))
fi

# GPU core clock (optional, for tooltip)
sclk=""
if [ -e "$card/pp_dpm_sclk" ]; then
    sclk=$(grep '\*' "$card/pp_dpm_sclk" 2>/dev/null | awk '{print $2}')
fi

text="󰢮 ${usage}%  ${temp_c}°"
tooltip="GPU  ${usage}%   ${temp_c}°C\nVRAM  ${vram_used_gb}G / ${vram_total_gb}G  (${vram_pct}%)"
[ -n "$sclk" ] && tooltip="${tooltip}\nCore  ${sclk}"

# emit compact JSON
printf '{"text":"%s","tooltip":"%s","class":"gpu"}\n' "$text" "$tooltip"
