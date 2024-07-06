<div align="center">

# RofiHud

GnomeHud fork with only Rofi implementation tailored for Arch Linux

## Installation

1. Install required GTK module:
   Run `chmod +x ./install && ./install`.
   Add `gtk-modules=appmenu-gtk-module` to `.config/gtk3.0/settings.ini`.

## Run

- Add `$HOME/.local/share/bin/globalhud/appmenu.py > /dev/null 2>&1 &` to autostart.
- Run with `python ./globalhud/command.py` to open the Rofi prompt, recommended by a keybind.

### Customization

In line 132 of `./globalhud/handlers/default.py`, you can modify Rofi arguments and themes.

The code is currently hardcoded to use the theme located at `$HOME/.config/rofi/themes/x.rasi`.

</div>
