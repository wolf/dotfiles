command -v fd >/dev/null || return

function f() { # f <pattern> : list all the files in or below . whose names match the given pattern
    fd --follow --no-ignore --hidden --glob "$@" 2>/dev/null
}

function fcat() { # fcat <pattern> : find all the files in or below . whose names match the given pattern and cat them
    fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch bat
}

function fcd() { # fcd <pattern> : find the first directory in or below . whose name matches the given pattern and cd into it
    # example: fcd js
    # example: fcd '*venv'
    # example: fcd --regex 'venv$'
    local FIRST_MATCHING_DIRECTORY

    FIRST_MATCHING_DIRECTORY="$(fd --follow --no-ignore --hidden --glob --type d --max-results 1 "$@" 2>/dev/null)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

function fcd_of { # fcd_of <pattern> : find the first file-system object in or below . whose name matches the given pattern, and cd into the directory that contains it
    local FIRST_MATCH
    local PARENT_OF_FIRST_MATCH

    FIRST_MATCH="$(fd --follow --no-ignore --hidden --glob --max-results 1 "$@" 2>/dev/null)"
    PARENT_OF_FIRST_MATCH="$(dirname "${FIRST_MATCH}")"

    if [ -d "${PARENT_OF_FIRST_MATCH}" ]; then
        cd "${PARENT_OF_FIRST_MATCH}" || return
    fi
}

function fe() { # fe <pattern> : find all the files in or below . whose names match the given pattern and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch ${EDITOR}
}

function fll() { # fll <pattern> : find all the files in or below . whose names match the given pattern, and list them as would ls -l
    fd --follow --no-ignore --hidden --glob "$@" --exec-batch exa -Fal
}

function fsource() { # fsource <pattern> : find all the files in or below . whose names match the given pattern and source them
    local FILES_TO_SOURCE
    declare -a FILES_TO_SOURCE

    readarray -d '' FILES_TO_SOURCE < <(fd --follow --no-ignore --hidden --glob --type f --print0 "$@")

    # shellcheck disable=SC1090,SC2086
    source "${FILES_TO_SOURCE[@]}"
}

function ftree() { # ftree [<path> [<pattern>]] : find all the file system objects in or below <path> whose names match <pattern> and display them as a tree
    local TARGET_DIR=${1:-.}
    local PATTERN=${2:-.}

    # Note the reversal.  This is the opposite of how fd normally works.
    fd --follow --hidden "${PATTERN}" "${TARGET_DIR}" | as-tree
}
