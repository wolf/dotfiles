command -v eza >/dev/null || return

alias ls=eza
alias ll="eza -Fal"
alias lgit="eza -Fal --tree --git --ignore-glob '.git' --icons"

function wll() { # wll <command> : find <command> (using which) and list it as with ls -l
    which "$@" | xargs eza -Fal
}
