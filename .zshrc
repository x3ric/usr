# ArchX zsh compatibility loader.
export ZDOTDIR="$HOME/.local/zsh"
export PATH="$HOME/.local/share/bin:$HOME/.local/bin:$PATH"
[ -f "$ZDOTDIR/.zshrc" ] && source "$ZDOTDIR/.zshrc"
