command -v fd >/dev/null || return

function f() { # f <pattern> : list all the files in or below . whose names match <pattern>.  You can give options to fd with all the f-commands
    fd --follow --hidden --glob --exclude ".git" "$@" 2>/dev/null
}

function fcat() { # fcat <pattern> : find all the files in or below . whose names match <pattern> and cat them
    fd --follow --hidden --glob --type f "$@" --exec-batch bat
}

function fcd() { # fcd <pattern> : find the first directory in or below . whose name matches <pattern> and cd into it
    # example: fcd js
    # example: fcd '*venv'
    # example: fcd --regex 'venv$'
    local FIRST_MATCHING_DIRECTORY

    FIRST_MATCHING_DIRECTORY="$(fd --follow --hidden --glob --type d --max-results 1 "$@" 2>/dev/null)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

function fcd_of { # fcd_of <pattern> : find the first file-system object in or below . whose name matches <pattern>, and cd into its parent
    local FIRST_MATCH
    local PARENT_OF_FIRST_MATCH

    FIRST_MATCH="$(fd --follow --hidden --glob --max-results 1 "$@" 2>/dev/null)"
    PARENT_OF_FIRST_MATCH="$(dirname "${FIRST_MATCH}")"

    if [ -d "${PARENT_OF_FIRST_MATCH}" ]; then
        cd "${PARENT_OF_FIRST_MATCH}" || return
    fi
}

function fe() { # fe <pattern> : find all the files in or below . whose names match <pattern> and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --hidden --glob --type f "$@" --exec-batch ${EDITOR}
}

function fll() { # fll <pattern> : find all the files in or below . whose names match <pattern>, and list them as would ls -l
    fd --follow --hidden --glob "$@" --exec-batch exa -Fal
}

function fsource() { # fsource <pattern> : find all the files in or below . whose names match <pattern> and source them
    local FILE FILES
    declare -a FILES
    readarray -d '' FILES < <(fd --follow --hidden --glob --type f --color=never --print0 "$@")
    for FILE in "${FILES[@]}" ; do
        echo source "\"${FILE}\""
        # shellcheck disable=SC1090,SC2086
        source "${FILE}"
    done
}
