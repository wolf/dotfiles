source_all() { # source_all file... : sources, in turn, each file given
    local FILE
    for FILE in "$@" ; do
        echo source "\"${FILE}\""
        # shellcheck disable=SC1090,SC2086
        source "${FILE}"
    done
}

be()   { sudo su -l "$@"; }                        # be <user> : start a login shell as user, but using your own sudo password

mkcd() {
    [ -n "$1" ] || return
    mkdir -p "$@" && cd "$1"
}
