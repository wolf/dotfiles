command -v fd >/dev/null || return

function fcat() { # fcat <pattern> : find all the files in or below . whose names match the given pattern and cat them
    fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch cat
}

function fe() { # fe <pattern> : find all the files in or below . whose names match the given pattern and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --no-ignore --hidden --glob --type f "$@" --path-separator="//" --print0 | xargs -o -0 ${EDITOR}
}

function fll() { # fll <pattern> : find all the files in or below . whose names match the given pattern, and list them as would ls -l
    fd --follow --no-ignore --hidden --list-details --glob "$@"
}
