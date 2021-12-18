export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_info() {
    [ "${VIRTUAL_ENV}" ] && echo ' ('$(basename "${VIRTUAL_ENV}")')';
}

# TODO: every place here I use bin/activate I probably need to test and possibly use Scripts/activate

function create_venv() {
    if [ -v VIRTUAL_ENV ] ; then
        deactivate
    fi
    if [[ -z "${1+x}" ]] ; then
        VENV_DIR="$(basename "$(pwd)")".venv
    else
        mkdir -p "$(dirname "$1")"
        VENV_DIR="$1"
    fi
    python -m venv --copies --upgrade-deps "$VENV_DIR"
    source "${VENV_DIR}/bin/activate"
    python -m pip install --upgrade wheel
}

function activate_found_venv() {
    if [ -v VIRTUAL_ENV ] ; then
        deactivate
    fi
    if [ -d .venv ] ; then
        VENV_DIR=.venv
    else
        VENV_DIR=$(command ls --color=never -d ./*.venv 2>/dev/null | head -n 1)
    fi
    if [[ -n "${VENV_DIR}" ]] ; then
        source ./"${VENV_DIR}"/bin/activate
    fi
}

function rename_venv() {
    FROM_NAME="${1}"
    TO_NAME="${2}"
    RANDOM_STRING=$(python -c "import uuid; print(str(uuid.uuid4()),end='')")
    TEMP_FILE_NAME=/tmp/${RANDOM_STRING}.requirements.txt

    source "${FROM_NAME}/bin/activate"
    python -m pip freeze > "${TEMP_FILE_NAME}"
    deactivate 2>/dev/null

    create_venv "${TO_NAME}"
    python -m pip install -r "${TEMP_FILE_NAME}"
    deactivate 2>/dev/null

    rm "${TEMP_FILE_NAME}"
    rm -rf "${FROM_NAME}"
}

function cdv() {
    cd "$1" || return
    activate_found_venv
}

export -f create_venv
export -f activate_found_venv
export -f rename_venv
