command -v rg >/dev/null || return

function ge() {
    # shellcheck disable=SC2086
    rg --hidden --files-with-matches "$@" | xargs -o ${EDITOR}
}
