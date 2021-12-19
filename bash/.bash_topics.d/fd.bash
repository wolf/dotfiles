command -v fd >/dev/null || return

if [ "$(command -v as-tree)" ] ; then
    function tree() {
        TARGET_DIR=${1:-.}
        PATTERN=${2:-.}
        # Note the reversal.  This is the opposite of how fd normally works.
        fd --follow --hidden "${PATTERN}" "${TARGET_DIR}" | as-tree
    }
fi

function f() {
    fd --follow --no-ignore --hidden --glob "$@" 2>/dev/null
}

function fcd() {
    # usage: fcd <pattern>
    # example: fcd js
    # example: fcd '*.venv'
    # example: fcd --regex 'venv$'
    # find the directory with the given name, cd-ing into the first match found
    FIRST_MATCHING_DIRECTORY="$(fd --type d --glob --hidden --no-ignore --max-results 1 "$@" 2>/dev/null)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

function en() {
    fd --type f --glob --follow --hidden --no-ignore "$@" --exec-batch "${EDITOR}"
}

if [ "$(command -v exa)" ] ; then
    function fx() {
        fd "$@" --exec-batch exa -Fal
    }
else
    function fx() {
        fd "$@" --exec-batch command ls --color -Falhd
    }
fi
