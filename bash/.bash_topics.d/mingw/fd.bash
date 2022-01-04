command -v fd >/dev/null || return

function fcat() { # fcat <pattern> : find all the files in or below . whose names match the given pattern and cat them
    fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch cat
}

function fll() { # fll <pattern> : find all the files in or below . whose names match the given pattern, and list them as would ls -l
    fd --follow --no-ignore --hidden --list-details --glob "$@"
}
