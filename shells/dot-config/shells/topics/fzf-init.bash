command -v fzf >/dev/null 2>&1 || return

eval "$(fzf --bash)"
