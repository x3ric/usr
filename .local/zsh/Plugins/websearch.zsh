## depending of xdg-utils
## https://github.com/theskumar/dotfiles/blob/master/.zsh/plugins/websearch/websearch.plugin.zsh

function websearch() {
  # get the open command
  local open_cmd
  [[ "$OSTYPE" = linux* ]] && open_cmd='xdg-open'
  [[ "$OSTYPE" = darwin* ]] && open_cmd='open'

  pattern='(google|duckduckgo|bing|yahoo|github|youtube)'

  # check whether the search engine is supported
  if [[ $1 =~ pattern ]];
  then
    echo "Search engine $1 not supported."
    return 1
  fi

  local url
  [[ "$1" == 'yahoo' ]] && url="https://search.yahoo.com" || url="https://www.$1.com"

  # no keyword provided, simply open the search engine homepage
  if [[ $# -le 1 ]]; then
    $open_cmd "$url"
    return
  fi

  typeset -A search_syntax=(
    google     "/search?q="
    bing       "/search?q="
    github     "/search?q="
    duckduckgo "/?q="
    yahoo      "/search?p="
    youtube    "/results?search_query="
  )

  url="${url}${search_syntax[$1]}"
  shift   # shift out $1

  while [[ $# -gt 0 ]]; do
    url="${url}$1+"
    shift
  done

  url="${url%?}" # remove the last '+'
  nohup $open_cmd "$url" &> /dev/null
}

alias bing='websearch bing'
alias google='websearch google'
alias yahoo='websearch yahoo'
alias ddg='websearch duckduckgo'
alias github='websearch github'
alias youtube='websearch youtube'

#add your own !bang searches here
alias wiki='websearch duckduckgo \!w'
alias news='websearch duckduckgo \!n'
alias map='websearch duckduckgo \!m'
alias image='websearch duckduckgo \!i'
alias ducky='websearch duckduckgo \!'
