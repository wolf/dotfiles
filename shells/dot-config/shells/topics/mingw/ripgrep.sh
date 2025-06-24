command -v rg >/dev/null 2>&1 || return

ge() { # ge <regexp> : find files in or below . whose contents somehow match <regexp>, and open them in $EDITOR
    # shellcheck disable=SC2086
    rg --follow --hidden --files-with-matches --path-separator="//" -0 "$@" | xargs -0 -o ${EDITOR}
}
