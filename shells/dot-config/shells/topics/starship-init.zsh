command -v starship >/dev/null 2>&1 || return

eval "$(starship init zsh)"
eval "$(starship completions zsh)"
