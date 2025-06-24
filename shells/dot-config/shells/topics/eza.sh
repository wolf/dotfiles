command -v eza >/dev/null 2>&1 || return

alias ls=eza
alias ll="eza -alF"

wll() { # wll <command> : find <command> (using which) and list it as with ls -l
    which "$@" | xargs eza -alF
}
