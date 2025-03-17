function drive_label() {
    local LABEL
    LABEL=$(printf "%s:" "${PWD:1:1}" | tr 'a-z' 'A-Z')

    if [[ $LABEL != "C:" ]] ; then
        echo "$LABEL"
    fi
}

export -f drive_label
