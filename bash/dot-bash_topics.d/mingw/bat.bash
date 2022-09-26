if command -v bat >/dev/null ; then
    alias cat="bat --pager='less -FRX' --wrap=never --theme=OneHalfLight"
fi
