command -v fd >/dev/null 2>&1 || return

f() { # f <glob> : list all the files in or below . whose names match <glob>.  You can give options to fd with all the f-commands
    fd --follow --hidden --glob "$@" 2>/dev/null
}

fcat() { # fcat <glob> : find all the files in or below . whose names match <glob> and cat them
    fd --follow --hidden --glob --type f "$@" --exec-batch bat
}

fcd() { # fcd <glob> : find the first directory in or below . whose name matches <glob> and cd into it
    local FIRST_MATCHING_DIRECTORY
    FIRST_MATCHING_DIRECTORY="$(fd --follow --hidden --glob --type d --max-results 1 "$@" 2>/dev/null)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

fcd_of() { # fcd_of <glob> : find the first file-system object in or below . whose name matches <glob>, and cd into its parent
    local FIRST_MATCH
    local PARENT_OF_FIRST_MATCH

    FIRST_MATCH="$(fd --follow --hidden --glob --max-results 1 "$@" 2>/dev/null)"
    PARENT_OF_FIRST_MATCH="$(dirname "${FIRST_MATCH}")"

    if [ -d "${PARENT_OF_FIRST_MATCH}" ]; then
        cd "${PARENT_OF_FIRST_MATCH}" || return
    fi
}

fe() { # fe <glob> : find all the files in or below . whose names match <glob> and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --hidden --glob --type f "$@" --exec-batch ${EDITOR}
}

fll() { # fll <glob> : find all the files in or below . whose names match <glob>, and list them as would ls -l
    fd --follow --hidden --glob "$@" --exec-batch eza -alF
}

fsource() { # fsource <glob> : find all the files in or below . whose names match <glob> and source them
    local FILES
    declare -a FILES
    readarray -d '' FILES < <(fd --follow --hidden --glob --type f --color=never --print0 "$@")
    source_all "${FILES[@]}"
}

if command -v as-tree >/dev/null 2>&1 ; then
    ftree() { # ftree <glob> : find all the files in or below . whose names match <glob> and display them as a tree
        fd --follow --hidden --glob "$@" | as-tree
    }
fi
