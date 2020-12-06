function activate_found_venv() {
    if [[ ! -z "$VIRTUAL_ENV" ]] ; then
        deactivate
    fi
    if [ -d .venv ] ; then
        VENV_DIR=.venv
    else
        VENV_DIR=$(ls -d *.venv 2>/dev/null | awk 'BEGIN { getline; print }')
    fi
    if [[ ! -z "$VENV_DIR" ]] ; then
        source ./$VENV_DIR/bin/activate
    fi
}

function cdv() {
    cd "$1"
    activate_found_venv
}
