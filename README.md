<div align="center">

# usr

> Personal Arch Linux dotfiles.  
> Opinionated, minimal, and built around my own workflow.

<br>

## Install

<pre>
curl -s https://raw.githubusercontent.com/X3ric/usr/refs/heads/main/.local/share/bin/archx | python3 - setup --yes
</pre>

Then run:

<pre>
archx
</pre>

Open **Configs** from the menu to install dotfiles, update configs, manage services, use Wi-Fi helpers, and run post-install tools.

<br>

<details>
<summary><h3>Custom configs</h3></summary>

<br>

Use another `usr` repository:

<pre>
ARCHX_USR_REPO="https://github.com/YOU/usr.git" archx setup --yes
</pre>

Use a specific branch or tag:

<pre>
ARCHX_USR_REPO="https://github.com/YOU/usr.git" ARCHX_USR_REF="main" archx setup --yes
</pre>

Use a local clone:

<pre>
ARCHX_USR_DIR="$HOME/my-usr" archx setup --yes
</pre>

<br>

</details>

<details>
<summary><h3>Hyprland</h3></summary>

<br>

Hyprland is the default Wayland setup.

Main config layout:

<pre>
~/.config/hypr/hyprland.conf
~/.config/hypr/conf.d/00-env.conf
~/.config/hypr/conf.d/10-startup.conf
~/.config/hypr/conf.d/20-monitor.conf
~/.config/hypr/conf.d/30-input.conf
~/.config/hypr/conf.d/40-look.conf
~/.config/hypr/conf.d/50-layouts.conf
~/.config/hypr/conf.d/60-binds.conf
~/.config/hypr/conf.d/70-rules.conf
~/.config/hypr/custom.conf
</pre>

Put machine-specific monitor, input, and app overrides in `custom.conf`.

Workspace-local window cycling:

<pre>
SUPER + Up    previous window
SUPER + Down  next window
</pre>

<br>

</details>

<details>
<summary><h3>Theme</h3></summary>

<br>

GTK: `darkarch`, based on [`Adwaita Amoled`](https://www.gnome-look.org/p/1553851)

Cursor: [`cz-Hickson-Black`](https://www.gnome-look.org/p/1503665)

Icons: [`Papirus`](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)

Colors are synced with `walset`, `pywal`, Waybar, Dunst, Kitty, and Hyprland borders.

<br>

</details>

<details>
<summary><h3>Binaries</h3></summary>

<br>

`archx`: ArchX installer, updater, and dotfile toolbox.

`walset`: wallpaper and theme color setter.

`ttywal`: TTY color helper.

`rofi-hud`: global menu / rofi HUD helper.

`record`: screen and region recording helper.

`explain`: aliases, functions, and helper command notes.

<br>

</details>

<details>
<summary><h3>Zsh helpers</h3></summary>

<br>

`plugins`: toggle `.zsh` plugin files.

`ytm-dl`: download MP3 files with thumbnails using [`yt-dlp`](https://github.com/yt-dlp/yt-dlp).

`walset -w`: select a wallpaper.

`walset -wc`: generate colors from the selected wallpaper.

`xrandr-set`: permanently set the primary display.

`record`: pick a region and record video.

`explain`: show available aliases, functions, and helper notes.

More helpers are listed by running `explain`.

<br>

</details>

<br>

<a href="https://archlinux.org">
  <img alt="Arch Linux" src="https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=D9E0EE&color=000000&labelColor=97A4E2">
</a>

<br><br>

<img src="https://x3ric.com/imgviews/?text=usr" alt="">

</div>