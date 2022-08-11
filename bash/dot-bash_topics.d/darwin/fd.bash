function fex() { # fex <glob> : find all the files in or below . whose names match <glob> and open them in an existing $EDITOR
    # shellcheck disable=SC2086
    fd --follow --hidden --glob --type f "$@" --exec-batch ${EDITOR} --remote
}
