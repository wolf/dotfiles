export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_info() {
    [ -v VIRTUAL_ENV ] && echo ' ('"$(basename "${VIRTUAL_ENV}")"')';
}

function deactivate_venv() {
    [ -v VIRTUAL_ENV ] || return
    if [ -v PYENV_VIRTUALENV_INIT ] ; then
        # shellcheck disable=SC1091
        source deactivate 2>/dev/null
    else
        deactivate
    fi
}

function activate_venv() {
    VENV_TO_ACTIVATE="${1}"
    [ -z "${VENV_TO_ACTIVATE}" ] && return
    deactivate_venv

    if [ -d "${VENV_TO_ACTIVATE}/bin" ] ; then
        # shellcheck disable=SC1091
        source "${VENV_TO_ACTIVATE}/bin/activate"
    elif [ -d "${VENV_TO_ACTIVATE}/Scripts" ] ; then
        # shellcheck disable=SC1091
        source "${VENV_TO_ACTIVATE}/Scripts/activate"
    fi
}

function create_venv() {
    deactivate_venv
    if [ -z "${1}" ] ; then
        VENV_DIR="$(basename "$(pwd)")".venv
    else
        mkdir -p "$(dirname "${1}")"
        VENV_DIR="${1}"
    fi
    python -m venv --copies --upgrade-deps "${VENV_DIR}"
    activate_venv "${VENV_DIR}"
    python -m pip install --upgrade wheel
    if [ -n "${2}" ] && [ -f "${2}" ] ; then
        python -m pip install -r "${2}"
    fi
}

function activate_found_venv() {
    deactivate_venv
    if [ -d .venv ] ; then
        VENV_DIR=.venv
    else
        VENV_DIR=$(command ls --color=never -d ./*venv 2>/dev/null | head -n 1)
    fi
    activate_venv "${VENV_DIR}"
}

function rename_venv() {
    FROM_NAME="${1}"
    TO_NAME="${2}"
    RANDOM_STRING=$(python -c "import uuid; print(str(uuid.uuid4()),end='')")
    TEMP_FILE_NAME=/tmp/${RANDOM_STRING}.requirements.txt

    activate_venv "${FROM_NAME}"
    python -m pip freeze > "${TEMP_FILE_NAME}"
    deactivate_venv

    create_venv "${TO_NAME}"
    python -m pip install -r "${TEMP_FILE_NAME}"
    deactivate 2>/dev/null

    rm "${TEMP_FILE_NAME}"
    rm -rf "${FROM_NAME}"
}

function cdv() {
    cd "${1}" || return
    activate_found_venv
}

export -f create_venv
export -f activate_found_venv
export -f rename_venv
