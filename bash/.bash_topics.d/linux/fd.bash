command -v fd >/dev/null || return

function fcd() { # fcd <pattern> : find the first directory in or below . whose name matches the given pattern and cd into it
    # example: fcd js
    # example: fcd '*venv'
    # example: fcd --regex 'venv$'
    local FIRST_MATCHING_DIRECTORY

    FIRST_MATCHING_DIRECTORY="$(fd --follow --no-ignore --hidden --type d --color=never "$@" 2>/dev/null | head -n 1)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

function fcd_of { # fcd_of <pattern> : find the first file-system object in or below . whose name matches the given pattern, and cd into the directory that contains it
    local FIRST_MATCH
    local PARENT_OF_FIRST_MATCH

    FIRST_MATCH="$(fd --follow --no-ignore --hidden --color=never "$@" 2>/dev/null | head -n 1)"
    PARENT_OF_FIRST_MATCH="$(dirname "${FIRST_MATCH}")"

    if [ -d "${PARENT_OF_FIRST_MATCH}" ]; then
        cd "${PARENT_OF_FIRST_MATCH}" || return
    fi
}
