command -v exa >/dev/null || return

alias ls=exa
alias ll="exa -Fal"
alias lgit="exa -Fal --tree --git --ignore-glob '.git' --icons"
