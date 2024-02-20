command -v eza >/dev/null || return

alias ls=eza
alias ll="eza -alF"
alias lgit="eza -alF --tree --git --ignore-glob '.git' --icons"

function wll() { # wll <command> : find <command> (using which) and list it as with ls -l
    which "$@" | xargs eza -alF
}
