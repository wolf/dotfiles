#!/usr/bin/env bash

if [ "$(command -v fdfind)" ] ; then
    alias fd=fdfind
fi

function platform() {
    local UNAME

    UNAME="$(uname)"
    UNAME="${UNAME,,}"
    if [[ ${UNAME} =~ mingw.* ]] ; then
        UNAME=mingw
    elif [[ ${UNAME} =~ cygwin.* ]] ; then
        UNAME=cygwin
    fi

    echo "${UNAME}"
}

function get_topics() { # get_topics [--print0] : prints the list of topics, in order, to be executed at interactive Bash startup
    fd --follow --no-ignore --hidden "$@" --max-depth=1 --type f --regex '.*\.bash$' "${HOME}/.bash_topics.d"
    fd --follow --no-ignore --hidden "$@"               --type f --regex '.*\.bash$' "${HOME}/.bash_topics.d/$(platform)"
}

export -f platform
export -f get_topics

function source_all() { # source_all file... : sources, in turn, each file given
    local FILE
    for FILE in "$@" ; do
        echo source "\"${FILE}\""
        # shellcheck disable=SC1090,SC2086
        source "${FILE}"
    done
}

function source_topics() { # source_topics : sources each of the files returned by get_topics, in order.  Does not source .bashrc
    local TOPICS
    declare -a TOPICS
    readarray -d '' TOPICS < <( get_topics --print0 )
    source_all "${TOPICS[@]}"
}

function mkcd() { mkdir -p "$@" && cd "${1}" || return; }   # mkcd <path> : create all directories needed to build <path> and cd into it
