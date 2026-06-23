#!/usr/bin/env bash
set -uo pipefail

action="$1"

case "$action" in
    PlayPause)
        playerctl play-pause 2>/dev/null || mpc toggle 2>/dev/null
        ;;
    Next)
        playerctl next 2>/dev/null || mpc next 2>/dev/null
        ;;
    Previous)
        playerctl previous 2>/dev/null || mpc prev 2>/dev/null
        ;;
    Stop)
        playerctl stop 2>/dev/null || mpc stop 2>/dev/null
        ;;
esac
