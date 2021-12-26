command -v fd >/dev/null || return

function f() { # f <pattern> : list all the files in or below . whose names match the given pattern
    fd --follow --no-ignore --hidden --glob "$@" 2>/dev/null
}

function fcat() { # fcat <pattern> : find all the files in or below . whose names match the given pattern and cat them
    fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch bat
}

function fcd() { # fcd <pattern> : find the first directory in or below . whose name matches the given pattern and cd into it
    # usage: fcd <pattern>
    # example: fcd js
    # example: fcd '*venv'
    # example: fcd --regex 'venv$'
    FIRST_MATCHING_DIRECTORY="$(fd --type d --glob --hidden --no-ignore --max-results 1 "$@" 2>/dev/null)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

function fe() { # fe <pattern> : find all the files in or below . whose names match the given pattern and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --type f --glob --follow --hidden --no-ignore "$@" --exec-batch ${EDITOR}
}

function fll() { # fll <pattern> : find all the files in or below . whose names match the given pattern, and list them as would ls -l
    fd --glob --follow --hidden "$@" --exec-batch exa -Fal
}

function fsource() { # fsource <pattern> : find all the files in or below . whose names match the given pattern and source them
    fd --follow --no-ignore --hidden --glob --type f "$@" --exec-batch source
}

function ftree() { # ftree [<path> [<pattern>]] : find all the file system objects in or below <path> whose names match <pattern> and display them as a tree
    TARGET_DIR=${1:-.}
    PATTERN=${2:-.}
    # Note the reversal.  This is the opposite of how fd normally works.
    fd --follow --hidden "${PATTERN}" "${TARGET_DIR}" | as-tree
}
