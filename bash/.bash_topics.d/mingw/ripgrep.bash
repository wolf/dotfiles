command -v rg >/dev/null || return

function ge() { # ge <regexp> : find files in or below . whose contents somehow match <regexp>, and open them in $EDITOR
    # shellcheck disable=SC2086
    rg --follow --hidden --files-with-matches --path-separator="//" "$@" | xargs -o ${EDITOR}
}
