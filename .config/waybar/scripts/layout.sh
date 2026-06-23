#!/usr/bin/env bash
set -uo pipefail

layout=$(hyprctl getoption general:layout | awk 'NR==1{print $2}') || layout="dwindle"
submap=$(hyprctl submap 2>/dev/null | tr -d '\n') || submap=""
mfact=$(hyprctl getoption master:mfact -j 2>/dev/null | jq -r '.float' 2>/dev/null || echo "0.5")

is_max=false
[ "$layout" = "master" ] && awk "BEGIN{exit($mfact >= 0.94 ? 0 : 1)}" && is_max=true

if $is_max; then
    icon="󰹔"; cls="max"
elif [ "$layout" = "dwindle" ]; then
    icon=""; cls="dwindle"
elif [ "$layout" = "master" ]; then
    icon=""; cls="master"
else
    icon="󰘖"; cls=""
fi

text="$icon"
[ -n "$submap" ] && [ "$submap" != "default" ] && text="$icon󰌐"

printf '{"text":"%s","class":"%s","alt":"%s"}\n' "$text" "$cls" "$layout"
