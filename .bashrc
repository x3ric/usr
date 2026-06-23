[[ $- != *i* ]] && return
BASH="/bin/bash"
export PATH="$PATH:$HOME/.local/bin:$HOME/.local/share/bin"
export ZDOTDIR="$HOME/.local/zsh"
export SHELL="$(command -v zsh 2>/dev/null || echo /bin/zsh)"
[ -f "$HOME/.local/zsh/envrc" ] && source "$HOME/.local/zsh/envrc"
[ -f "$HOME/.local/zsh/aliasrc" ] && source "$HOME/.local/zsh/aliasrc"
PS1='\[\033[38;5;3m\]\u\[\e[32m\]\w\[\e[36m\]❯ \[\e[0m\]'
