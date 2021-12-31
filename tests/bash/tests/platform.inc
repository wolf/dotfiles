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
