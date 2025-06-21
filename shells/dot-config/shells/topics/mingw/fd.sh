command -v fd >/dev/null 2>&1 || return

fcat() { # fcat <glob> : find all the files in or below . whose names match <glob> and cat them
    fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch cat
}

fe() { # fe <glob> : find all the files in or below . whose names match <glob> and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --no-ignore --hidden --glob --type f "$@" --path-separator="//" --print0 | xargs -o -0 ${EDITOR}
}

fll() { # fll <glob> : find all the files in or below . whose names match <glob>, and list them as would ls -l
    fd --follow --no-ignore --hidden --list-details --glob "$@"
}
