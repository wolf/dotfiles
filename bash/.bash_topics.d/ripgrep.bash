command -v rg >/dev/null || return

export RIPGREP_CONFIG_PATH=~/.config/rg/config

function ge() {
    # shellcheck disable=SC2086
    rg --hidden --files-with-matches "$@" | xargs -o ${EDITOR}
}
