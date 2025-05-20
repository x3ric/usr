if [ -z "$NEOFETCH_RUNNED" ] && [ -n "$DISPLAY" ] ; then
    NEOFETCH_RUNNED=1
    export NEOFETCH_RUNNED
    [ $(pgrep -cx kitty) -eq 1 ] && neofetch
fi
CONFSIZE=$(du -sb "$HOME/.local/zsh" | awk '{print $1}') # shell config size
eval $(thefuck --alias)
stty -ixon
setopt correct
setopt appendhistory
setopt autocd
setopt cdablevars
setopt extended_glob
setopt dotglob
setopt glob_complete
# Completion
  autoload -U compinit
  zstyle ':completion:*' menu select
  zmodload zsh/complist
  compinit
  _comp_options+=(globdots) ## Include hidden files.
  #ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"	# To get colored completion text
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(buffer-empty bracketed-paste accept-line push-line-or-edit)
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_USE_ASYNC=true
# Notify
  bgnotify_threshold=4
  function notify_formatted {
    #$1=exit_status, $2=command, $3=elapsed_time
    [ $1 -eq 0 ] && title="Task completed!"
    bgnotify "$title -- after $3 s" "$2";
  }
# Configs
#command_not_found_handler() { # zsh handlers nyack
#  CONFSZ=$(du -sb "$HOME/.local/zsh" | awk '{print $1}')
#  if [[ $CONFSIZE != $CONFSZ ]]; then
#    source "$HOME/.local/zsh/.zshrc"
#    if command -v "$1" >/dev/null 2>&1 || alias "$1" >/dev/null 2>&1 || functions "$1" >/dev/null 2>&1; then
#      zsh -ci "unsetopt correct;$@; exit"
#      return 0
#    fi
#  else
#    nyack "$@" || return 1
#  fi
#}
if [[ -z $SSH_TTY ]] && [[ ! -z $tty ]]; then 
	scroll() { # Scrolling on tty
		if ! command -v scrollback &>/dev/null; then	
			[ ! -z "$HOME/.local/share/opt/scrollback/" ] && cd "$HOME/.local/share/opt/scrollback/" && make && sudo make install
		else
			scrollvt='true'
			! $SCROLLBACK false && scrollback -c "$SHELL"
			scrollback "$SHELL"
			unset scrollvt
		fi
	}	
fi
source /$HOME/.local/zsh/Internal/source
