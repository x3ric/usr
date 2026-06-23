# ArchX user environment
export PATH="$HOME/.local/share/bin:$HOME/.local/bin:$PATH"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export GTK_THEME="${GTK_THEME:-darkarch}"
export XCURSOR_THEME="${XCURSOR_THEME:-cz-Hickson-Black}"
export XCURSOR_SIZE="${XCURSOR_SIZE:-24}"
export HYPRCURSOR_THEME="${HYPRCURSOR_THEME:-cz-Hickson-Black}"
export HYPRCURSOR_SIZE="${HYPRCURSOR_SIZE:-24}"
export MOZ_ENABLE_WAYLAND=1

archx_start_hyprland_tty1() {
    [ -z "${SSH_TTY:-}" ] || return 0
    [ -z "${DISPLAY:-}" ] || return 0
    [ -z "${WAYLAND_DISPLAY:-}" ] || return 0
    [ "$(tty 2>/dev/null)" = "/dev/tty1" ] || return 0
    command -v start-hyprland >/dev/null 2>&1 || return 0
    exec start-hyprland
}
archx_start_hyprland_tty1
