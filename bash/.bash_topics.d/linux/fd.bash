command -v fd >/dev/null || return

function f() { # f <regexp> : list all the files in or below . whose names match <regexp>.  You can give options to fd with all the f-commands
    fd --follow --hidden "$@" 2>/dev/null
}

function fcat() { # fcat <regexp> : find all the files in or below . whose names match <regexp> and cat them
    fd --follow --hidden --type f "$@" --exec-batch bat
}

function fcd() { # fcd <regexp> : find the first directory in or below . whose name matches <regexp> and cd into it
    local FIRST_MATCHING_DIRECTORY
    FIRST_MATCHING_DIRECTORY="$(fd --follow --hidden --type d --color=never "$@" 2>/dev/null | head -n 1)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

function fcd_of { # fcd_of <regexp> : find the first file-system object in or below . whose name matches <regexp>, and cd into its parent
    local FIRST_MATCH
    local PARENT_OF_FIRST_MATCH

    FIRST_MATCH="$(fd --follow --hidden --color=never "$@" 2>/dev/null | head -n 1)"
    PARENT_OF_FIRST_MATCH="$(dirname "${FIRST_MATCH}")"

    if [ -d "${PARENT_OF_FIRST_MATCH}" ]; then
        cd "${PARENT_OF_FIRST_MATCH}" || return
    fi
}

function fe() { # fe <regexp> : find all the files in or below . whose names match <regexp> and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --hidden --type f "$@" --exec-batch ${EDITOR}
}

function fll() { # fll <regexp> : find all the files in or below . whose names match <regexp>, and list them as would ls -l
    fd --follow --hidden "$@" --exec-batch exa -Fal
}

function fsource() { # fsource <regexp> : find all the files in or below . whose names match <regexp> and source them
    local FILE FILES
    declare -a FILES
    readarray -d '' FILES < <(fd --follow --hidden --type f --color=never --print0 "$@")
    for FILE in "${FILES[@]}" ; do
        echo source "\"${FILE}\""
        # shellcheck disable=SC1090,SC2086
        source "${FILE}"
    done
}
