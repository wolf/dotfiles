# Note: this is needed by Starship, but only on Windows, which is Bash only.
# Therefore, `export -f` is acceptable.

drive_label() {
    local LABEL
    LABEL=$(printf "%s:" "${PWD:1:1}" | tr 'a-z' 'A-Z')

    if [[ $LABEL != "C:" ]] ; then
        echo "$LABEL"
    fi
}

export -f drive_label
