#!/usr/bin/env bash
set -Eeuo pipefail

pacman_pkgs=(
  hyprland xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  waybar dunst wl-clipboard cliphist grim slurp swappy jq libnotify brightnessctl
  pipewire wireplumber pavucontrol hyprpicker imagemagick nwg-clipman
  rofi kitty thunar btop wofi python python-pillow python-pytesseract
  tesseract tesseract-data-eng playerctl mpd mpc pacman-contrib
)

aur_pkgs=(grimblast-git wlogout)

echo ":: Installing Hyprland/Waybar dependencies"
sudo pacman -S --needed --noconfirm "${pacman_pkgs[@]}"

if ((${#aur_pkgs[@]})); then
  if command -v yay >/dev/null 2>&1; then
    yay -S --needed --noconfirm "${aur_pkgs[@]}"
  elif command -v paru >/dev/null 2>&1; then
    paru -S --needed --noconfirm "${aur_pkgs[@]}"
  else
    echo ":: AUR helper missing; install manually: ${aur_pkgs[*]}"
  fi
fi

echo ":: Done"
