# Runned on shell start
if [ -z "$NEOFETCH_RUNNED" ] && [ -n "$DISPLAY" ] ; then
    NEOFETCH_RUNNED=1
    export NEOFETCH_RUNNED
    [ $(pgrep -cx kitty) -eq 1 ] && neofetch
fi
CONFSIZE=$(du -sb "$HOME/.config/zsh" | awk '{print $1}') # shell config size
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
[ -f "$HOME/.local/zsh/private" ] && source "$HOME/.local/zsh/private"
[ ! -d "$HOME/.local/share/gnupg" ] && mkdir -p "$HOME/.local/share/gnupg"
[ -f "$HOME/.config/zsh/envrc" ] && source "$HOME/.config/zsh/envrc"
[ -f "$HOME/.config/zsh/aliasrc" ] && source "$HOME/.config/zsh/aliasrc"
[ -f "$HOME/.config/zsh/funcrc" ] && source "$HOME/.config/zsh/funcrc"
[ -f "$HOME/.config/zsh/comprc" ] && source "$HOME/.config/zsh/comprc"
[ -f "$HOME/.config/zsh/comprc" ] && source "$HOME/.config/zsh/inputrc"
command_not_found_handler() { # zsh handlers
  CONFSZ=$(du -sb "$HOME/.config/zsh" | awk '{print $1}')
  if [[ $CONFSIZE != $CONFSZ ]]; then
    source "$HOME/.config/zsh/.zshrc"
    if command -v "$1" >/dev/null 2>&1 || alias "$1" >/dev/null 2>&1 || functions "$1" >/dev/null 2>&1; then
      zsh -ci "unsetopt correct;$@; exit"
      return 0
    fi
  else
    nyack "$@" || return 1
  fi
}
if [[ (-z $tty) || (! -z $TMUX) ]] ; then # tty promt
  source /$HOME/.config/zsh/Internal/p10k.zsh
  source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
else
  PS1='%F{green}['$USER'%F{yellow}@%F{blue}%~%F{green}]%F{reset}%# '
fi
source /$HOME/.config/zsh/Internal/async.plugin.zsh
source /$HOME/.config/zsh/Internal/fzf-tab.plugin.zsh
source /$HOME/.config/zsh/Internal/fzf-key-bindings.plugins.zsh
source /$HOME/.config/zsh/Internal/fzf-completion.plugin.zsh
source /$HOME/.config/zsh/Internal/forgit.plugin.zsh
source /$HOME/.config/zsh/Internal/bgnotify.plugin.zsh
source /$HOME/.config/zsh/Internal/zsh-autoquoter.zsh
source /$HOME/.config/zsh/Internal/nice-exit-code.plugin.zsh
source /$HOME/.config/broot/launcher/bash/br
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
[[ -s /etc/profile.d/autojump.sh ]] && source /etc/profile.d/autojump.sh 2>/dev/null
