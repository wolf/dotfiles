command -v rg >/dev/null 2>&1 || return

# An alias and a couple of functions for interactive use.

export RIPGREP_CONFIG_PATH="${HOME}/.config/rg/config"

g() { # g <regexp> : find matches in files in or below .  You can provide options to rg with all the g-functions
    # shellcheck disable=SC2086
    rg --follow --hidden --smart-case --heading "$@"
}

alias grep=g

ge() { # ge <regexp> : find files in or below . whose contents somehow match <regexp>, and open them in `$EDITOR`
    # shellcheck disable=SC2086
    rg --follow --hidden --smart-case --files-with-matches -0 "$@" | xargs -0 -o ${EDITOR}
}
