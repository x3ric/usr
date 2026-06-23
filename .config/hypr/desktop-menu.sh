#!/usr/bin/env bash
set -uo pipefail

entries=" Terminal\n󰈹 Browser\n󰉋 Files\n󰨞 Code\n Settings\n Lock\n⏻ Power"

selected=$(echo -e "$entries" | wofi --dmenu -p "" --width 200 --height 260 --cache-file /dev/null 2>/dev/null)

case $selected in
    *Terminal)  kitty ;;
    *Browser)   firefox ;;
    *Files)     thunar ;;
    *Code)      code ;;
    *Settings)  gnome-control-center ;;
    *Lock)      loginctl lock-session ;;
    *Power)     wlogout ;;
esac
