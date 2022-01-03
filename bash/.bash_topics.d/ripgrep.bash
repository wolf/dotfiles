command -v rg >/dev/null || return

export RIPGREP_CONFIG_PATH=~/.config/rg/config

function g() { # g <pattern> : find matches in files in or below .
    # shellcheck disable=SC2086
    rg --follow --hidden --smart-case --heading "$@"
}

alias grep='g'

function ge() { # ge <pattern> : find files in or below . whose contents somehow match pattern, and open them in $EDITOR
    # shellcheck disable=SC2086
    rg --follow --hidden --smart-case --files-with-matches "$@" | xargs -o ${EDITOR}
}
