command -v fd >/dev/null 2>&1 || return

f() { # f <regexp> : list all the files in or below . whose names match <regexp>.  You can give options to fd with all the f-commands
    fd --follow --hidden "$@" 2>/dev/null
}

fcat() { # fcat <regexp> : find all the files in or below . whose names match <regexp> and cat them
    fd --follow --hidden --type f "$@" --exec-batch bat
}

fcd() { # fcd <regexp> : find the first directory in or below . whose name matches <regexp> and cd into it
    local FIRST_MATCHING_DIRECTORY
    FIRST_MATCHING_DIRECTORY="$(fd --follow --hidden --type d --color=never "$@" 2>/dev/null | head -n 1)"
    if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
        cd "${FIRST_MATCHING_DIRECTORY}" || return
    fi
}

fcd_of() { # fcd_of <regexp> : find the first file-system object in or below . whose name matches <regexp>, and cd into its parent
    local FIRST_MATCH
    local PARENT_OF_FIRST_MATCH

    FIRST_MATCH="$(fd --follow --hidden --color=never "$@" 2>/dev/null | head -n 1)"
    PARENT_OF_FIRST_MATCH="$(dirname "${FIRST_MATCH}")"

    if [ -d "${PARENT_OF_FIRST_MATCH}" ]; then
        cd "${PARENT_OF_FIRST_MATCH}" || return
    fi
}

fe() { # fe <regexp> : find all the files in or below . whose names match <regexp> and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --hidden --type f "$@" --exec-batch ${EDITOR}
}

fll() { # fll <regexp> : find all the files in or below . whose names match <regexp>, and list them as would ls -l
    fd --follow --hidden "$@" --exec-batch eza -alF
}

fsource() { # fsource <regexp> : find all the files in or below . whose names match <regexp> and source them
    local FILES
    declare -a FILES
    readarray -d '' FILES < <(fd --follow --hidden --type f --color=never --print0 "$@")
    source_all "${FILES[@]}"
}

if command -v as-tree >/dev/null 2>&1 ; then
    ftree() { # ftree <regexp> : find all the files in or below . whose names match <regexp> and display them as a tree
        fd --follow --hidden "$@" | as-tree
    }
fi
