command -v fd >/dev/null || return

function fll() { # fll <pattern> : find all the files in or below . whose names match the given pattern, and list them as would ls -l
    fd --follow --no-ignore --hidden --list-details --glob "$@"
}
