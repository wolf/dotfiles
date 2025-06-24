command -v starship >/dev/null 2>&1 || return

eval "$(starship init bash)"
eval "$(starship completions bash)"
