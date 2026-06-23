#!/usr/bin/env bash
set -uo pipefail

wal_css="$HOME/.cache/wal/colors.css"
border_file="$HOME/.cache/hypr/border_color"
accent=""

if [ -f "$wal_css" ]; then
    accent=$(grep -oP -- '--color5:\s*#\K[0-9a-fA-F]{6}' "$wal_css" 2>/dev/null | head -1)
fi
if [ -z "$accent" ]; then
    accent=$(grep -oP -- '--color4:\s*#\K[0-9a-fA-F]{6}' "$wal_css" 2>/dev/null | head -1)
fi
if [ -z "$accent" ]; then
    accent="BB86FC"
fi

mkdir -p "$(dirname "$border_file")"
echo "$accent" > "$border_file"

hyprctl keyword general:col.active_border "rgba(${accent}E5)" 2>/dev/null
hyprctl keyword general:col.inactive_border "rgba(1A1A2EEE)" 2>/dev/null
