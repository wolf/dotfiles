command -v rg >/dev/null || return

export RIPGREP_CONFIG_PATH=~/.config/rg/config

alias grep="rg"

function ge() { # ge <pattern> : find files in or below . whose contents somehow match pattern, and open them in $EDITOR
    # shellcheck disable=SC2086
    rg --follow --hidden --files-with-matches "$@" | xargs -o ${EDITOR}
}
