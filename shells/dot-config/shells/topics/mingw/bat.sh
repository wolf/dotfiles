command -v bat >/dev/null 2>&1 || return

alias cat="bat --pager='less -FRX' --wrap=never --theme=OneHalfLight"
