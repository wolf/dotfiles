command -v rg >/dev/null || return

export RIPGREP_CONFIG_PATH=~/.config/rg/config

function ge() { # ge <pattern> : find files in or below . whose contents somehow match pattern, and open them in $EDITOR
    # shellcheck disable=SC2086
    rg --hidden --files-with-matches "$@" | xargs -o ${EDITOR}
}


function help() { # help : you're soaking in it!
    rg --hidden --color=never --no-line-number \
        -e '\s*(?:function|alias)\s+([a-z][a-z0-9_]*).*(#.*)' \
        --replace "\$1		\$2" \
        "${DOTFILES_DIR}/bash"
}
