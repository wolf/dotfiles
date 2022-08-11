command -v exa >/dev/null || return

alias ls=exa
alias ll="exa -Fal"
alias lgit="exa -Fal --tree --git --ignore-glob '.git' --icons"

function wll() { # wll <command> : find <command> (using which) and list it as with ls -l
    which "$@" | xargs exa -Fal
}
