#!/usr/bin/env bash

if [ "$(command -v fdfind)" ] ; then
    alias fd=fdfind
fi

function source_all() { # source_all file... : sources, in turn, each file given
    local FILE
    for FILE in "$@" ; do
        echo source "\"${FILE}\""
        # shellcheck disable=SC1090,SC2086
        source "${FILE}"
    done
}

function source_topics() { # source_topics : sources each of the files returned by get_topics.py, in order.  Does not source .bashrc
    local TOPICS
    declare -a TOPICS
    readarray -d '' TOPICS < <( get_topics.py --print0 )
    source_all "${TOPICS[@]}"
}

function mkcd() { [[ -n "$1" ]] && mkdir -p "$@" && cd "${1}" || return; }   # mkcd <path> : create all directories needed to build <path> and cd into it
