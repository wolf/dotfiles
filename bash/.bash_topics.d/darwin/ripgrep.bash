function gex() { # gex <regexp> : find files in or below . whose contents somehow match <regexp>, and open them in an existing $EDITOR
    # shellcheck disable=SC2086
    rg --follow --hidden --smart-case --files-with-matches -0 "$@" | xargs -0 -o ${EDITOR} --remote
}
