command -v fd >/dev/null || return

function f() { # f <glob> : list all the files in or below . whose names match <glob>.  You can give options to fd with all the f-commands
    fd --follow --hidden --glob "$@" 2>/dev/null
}

function fcat() { # fcat <glob> : find all the files in or below . whose names match <glob> and cat them
    fd --follow --hidden --glob --type f "$@" --exec-batch bat
}

function fcd() { # fcd <glob> : find the first directory in or below . whose name matches <glob> and cd into it
    local FIRST_MATCHING_DIRECTORY
    FIRST_MATCHING_DIRECTORY="$(fd --follow --hidden --glob --type d --max-results 1 "$@" 2>/dev/null)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

function fcd_of { # fcd_of <glob> : find the first file-system object in or below . whose name matches <glob>, and cd into its parent
    local FIRST_MATCH
    local PARENT_OF_FIRST_MATCH

    FIRST_MATCH="$(fd --follow --hidden --glob --max-results 1 "$@" 2>/dev/null)"
    PARENT_OF_FIRST_MATCH="$(dirname "${FIRST_MATCH}")"

    if [ -d "${PARENT_OF_FIRST_MATCH}" ]; then
        cd "${PARENT_OF_FIRST_MATCH}" || return
    fi
}

function fe() { # fe <glob> : find all the files in or below . whose names match <glob> and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --hidden --glob --type f "$@" --exec-batch ${EDITOR}
}

function fll() { # fll <glob> : find all the files in or below . whose names match <glob>, and list them as would ls -l
    fd --follow --hidden --glob "$@" --exec-batch exa -Fal
}

function fsource() { # fsource <glob> : find all the files in or below . whose names match <glob> and source them
    local FILE FILES
    declare -a FILES
    readarray -d '' FILES < <(fd --follow --hidden --glob --type f --color=never --print0 "$@")
    for FILE in "${FILES[@]}" ; do
        echo source "\"${FILE}\""
        # shellcheck disable=SC1090,SC2086
        source "${FILE}"
    done
}

if [ "$(command -v as-tree)" ] ; then
    function ftree() { # ftree <glob> : find all the files in or below . whose names match <glob> and display them as a tree
        fd --follow --hidden --glob "$@" | as-tree
    }
fi
