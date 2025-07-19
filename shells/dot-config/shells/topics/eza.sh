command -v eza >/dev/null 2>&1 || return

unset LS_COLORS
unset EXA_COLORS
unset EZA_COLORS

export EZA_CONFIG_DIR="${HOME}/.config/eza"

alias ls=eza
alias ll="eza -alF"

wll() { # wll <command> : find <command> (using which) and list it as with ls -l
    which "$@" | xargs eza -alF
}
