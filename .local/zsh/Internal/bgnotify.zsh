#!/usr/bin/env zsh

## setup ##

[[ -o interactive ]] || return #interactive only!
zmodload zsh/datetime || { print "can't load zsh/datetime"; return } # faster than date()
autoload -Uz add-zsh-hook || { print "can't add zsh hook!"; return }

(( ${+bgnotify_threshold} )) || bgnotify_threshold=5 # default 5 seconds


## definitions ##

bgnotify_is_disabled () {
  [[ -n "$BGNOTIFY_DISABLE" ]]
}

if ! (type bgnotify_formatted | grep -q 'function'); then ## allow custom function override
  function bgnotify_formatted { ## args: (exit_status, command, elapsed_seconds)
    elapsed="$(( $3 % 60 ))s"
    (( $3 >= 60 )) && elapsed="$((( $3 % 3600) / 60 ))m $elapsed"
    (( $3 >= 3600 )) && elapsed="$(( $3 / 3600 ))h $elapsed"
    [ $1 -eq 0 ] && bgnotify "#win (took $elapsed)" "$2" || bgnotify "#fail (took $elapsed)" "$2"
  }
fi

currentWindowId () {
  if hash osascript 2>/dev/null; then #osx
    osascript -e 'tell application (path to frontmost application as text) to id of front window' 2>/dev/null || echo "0"
  elif (hash notify-send 2>/dev/null || hash kdialog 2>/dev/null); then #linux
    xprop -root 2>/dev/null | awk '/NET_ACTIVE_WINDOW/{print $5;exit} END{exit !$5}' || echo "0"
  else
    echo $EPOCHSECONDS #fallback for windows
  fi
}

bgnotify () { ## args: (title, subtitle)
  bgnotify_is_disabled && return 0

  if hash terminal-notifier 2>/dev/null; then #osx
    [[ "$TERM_PROGRAM" == 'iTerm.app' ]] && term_id='com.googlecode.iterm2'
    [[ "$TERM_PROGRAM" == 'Apple_Terminal' ]] && term_id='com.apple.terminal'
    ## now call terminal-notifier, (hopefully with $term_id!)
    [ -z "$term_id" ] && terminal-notifier -message "$2" -title "$1" >/dev/null 2>/dev/null ||
    terminal-notifier -message "$2" -title "$1" -activate "$term_id" -sender "$term_id" >/dev/null 2>/dev/null
  elif hash growlnotify 2>/dev/null; then #osx growl
    growlnotify -m "$1" "$2" >/dev/null 2>/dev/null || true
  elif hash notify-send 2>/dev/null; then #linux gnome
    notify-send "$1" "$2" >/dev/null 2>/dev/null || true
  elif hash kdialog 2>/dev/null; then #linux kde
    kdialog -title "$1" --passivepopup "$2" 5 >/dev/null 2>/dev/null || true
  elif hash notifu 2>/dev/null; then #cygwin support
    notifu /m "$2" /p "$1" >/dev/null 2>/dev/null || true
  fi
}


## Zsh hooks ##

bgnotify_skip_once=0

bgnotify_begin() {
  bgnotify_timestamp=$EPOCHSECONDS
  bgnotify_lastcmd="$1"
  bgnotify_windowid=$(currentWindowId)
  if [[ "$1" == *"BGNOTIFY_DISABLE=1"* ]]; then
    bgnotify_skip_once=1
  else
    bgnotify_skip_once=0
  fi
}

bgnotify_end() {
  didexit=$?
  elapsed=$(( EPOCHSECONDS - bgnotify_timestamp ))
  past_threshold=$(( elapsed >= bgnotify_threshold ))

  if bgnotify_is_disabled || (( bgnotify_skip_once )); then
    bgnotify_timestamp=0
    bgnotify_skip_once=0
    return
  fi

  if (( bgnotify_timestamp > 0 )) && (( past_threshold )); then
    if [ "$(currentWindowId)" != "$bgnotify_windowid" ]; then
      print -n "\a"
      bgnotify_formatted "$didexit" "$bgnotify_lastcmd" "$elapsed"
    fi
  fi

  bgnotify_timestamp=0
  bgnotify_skip_once=0
}

## only enable if a local (non-ssh) connection
if [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  add-zsh-hook preexec bgnotify_begin
  add-zsh-hook precmd bgnotify_end
fi
