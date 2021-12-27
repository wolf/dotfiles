function f() {
    # "find..."
    # usage: f <name> [...]
    # example: f Makefile
    # example: f Makefile -type f
    # find the filesystem object with the given name
    find . -name "$@" 2>/dev/null
}

function fcat () {
    find . -type f -print0 -name "$@" 2>/dev/null | xargs -0 cat
}

function fcd() {
    # "find and cd into..."
    # usage: fcd <pattern>
    # example: fcd js
    # find the directory with the given name, cd-ing into the first match found
    local FIRST_MATCHING_DIRECTORY

    FIRST_MATCHING_DIRECTORY="$(find . -type d -name "$@" 2>/dev/null | head -n 1)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

function fe() {
    # "edit by name"
    # usage: fe <name>
    # example: fe .bashrc
    # find the files with the given name in or below . and open them in the default editor

    # shellcheck disable=SC2086
    find . -type f -print0 -name "$1" 2>/dev/null | xargs -o -0 ${EDITOR}
}

function fll() {
    # "find and list files in long format"
    # usage: fll <pattern>
    # example: fll '*.bash'
    # find the filesystem objects matching the given pattern in or below .

    # shellcheck disable=SC2033
    find . -name "$@" -print0 2>/dev/null | xargs -0 ls --color -Falhd
}
