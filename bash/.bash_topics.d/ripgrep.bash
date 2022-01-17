command -v rg >/dev/null || return

export RIPGREP_CONFIG_PATH=~/.config/rg/config

function g() { # g <regexp> : find matches in files in or below .  You can provide options to rg with all the g-functions
    # shellcheck disable=SC2086
    rg --follow --hidden --smart-case --heading "$@"
}

alias grep='g'

function ge() { # ge <regexp> : find files in or below . whose contents somehow match <regexp>, and open them in $EDITOR
    # shellcheck disable=SC2086
    rg --follow --hidden --smart-case --files-with-matches -0 "$@" | xargs -0 -o ${EDITOR}
}
