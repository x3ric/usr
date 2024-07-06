[[ $- != *i* ]] && return
BASH="/bin/bash"
PATH="$PATH:/$HOME/.local/bin"
PATH="$PATH:/$HOME/.local/share/bin"
export ZDOTDIR=~/.config/zsh
[ -f "$HOME/.config/zsh/envrc" ] && source "$HOME/.config/zsh/envrc"
[ -f "$HOME/.config/zsh/aliasrc" ] && source "$HOME/.config/zsh/aliasrc"
PS1='\[\033[38;5;2m\][\]\[\033[38;5;3m\]\u\[\033[38;5;11m\]@\[\033[38;5;4m\]\W\[\033[38;5;2m\]]\[\033[0m\]% '
