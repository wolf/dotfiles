export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_info() {
    [ -v VIRTUAL_ENV ] && echo ' ('"$(basename "${VIRTUAL_ENV}")"')';
}

function deactivate_venv() { # deactivate_venv : deactivate the currently active venv, if any, whether using pyenv-virtualenvs or not
    [ -v VIRTUAL_ENV ] || return
    if [ -v PYENV_VIRTUALENV_INIT ] ; then
        # shellcheck disable=SC1091
        source deactivate 2>/dev/null
    else
        deactivate
    fi
}

function activate_venv() { # activate_venv <venv>
    local VENV_TO_ACTIVATE="${1}"

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

function activate_found_venv() { # activate_found_venv : activate the venv found in the current directory
    local VENV_DIR

    deactivate_venv
    if [ -d .venv ] ; then
        VENV_DIR=.venv
    else
        VENV_DIR="$(command ls --color=never -d ./*venv 2>/dev/null | head -n 1)"
    fi
    activate_venv "${VENV_DIR}"
}

function cdv() { # cdv [<path>] : cd into <path>, if given, or else $HOME; and activate the venv found there
    local DESTINATION_DIR="${1:-"${HOME}"}"
    deactivate_venv
    cd "${DESTINATION_DIR}" || return
    activate_found_venv
}

# Based on the cd completion function from the bash_completion package
# Adapted from: https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#index-complete
function _comp_cdv()
{
    local IFS=$' \t\n'    # normalize IFS
    local cur _skipdot _cdpath
    local i j k

    # Tilde expansion, which also expands tilde to full pathname
    case "$2" in
    \~*)    eval cur="$2" ;;
    *)      cur=$2 ;;
    esac

    # no cdpath or absolute pathname -- straight directory completion
    if [[ -z "${CDPATH:-}" ]] || [[ "$cur" == @(./*|../*|/*) ]]; then
        # compgen prints paths one per line; could also use while loop
        IFS=$'\n'
        COMPREPLY=( $(compgen -d -- "$cur") )
        IFS=$' \t\n'
    # CDPATH+directories in the current directory if not in CDPATH
    else
        IFS=$'\n'
        _skipdot=false
        # preprocess CDPATH to convert null directory names to .
        _cdpath=${CDPATH/#:/.:}
        _cdpath=${_cdpath//::/:.:}
        _cdpath=${_cdpath/%:/:.}
        for i in ${_cdpath//:/$'\n'}; do
            if [[ $i -ef . ]]; then _skipdot=true; fi
            k="${#COMPREPLY[@]}"
            for j in $( compgen -d -- "$i/$cur" ); do
                COMPREPLY[k++]=${j#$i/}        # cut off directory
            done
        done
        $_skipdot || COMPREPLY+=( $(compgen -d -- "$cur") )
        IFS=$' \t\n'
    fi

    # variable names if appropriate shell option set and no completions
    if shopt -q cdable_vars && [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        COMPREPLY=( $(compgen -v -- "$cur") )
    fi

    return 0
}

complete -o filenames -o nospace -o bashdefault -F _comp_cdv cdv

function create_venv() { # create_venv [<path> [requirements]] : create a venv at path, or if none given, at <cwd>/<cwd>.venv, installing packages named in <requirements>
    local VENV_DIR

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

function rename_venv() { # rename_venv <path-to-existing-venv> <new-name> : rename a venv, keeping all installed packages
    local RANDOM_STRING
    RANDOM_STRING="$(python3 -c "import uuid; print(str(uuid.uuid4()),end='')")"

    local FROM_NAME="${1}"
    local TO_NAME="${2}"
    local TEMP_FILE_NAME=/tmp/${RANDOM_STRING}.requirements.txt

    activate_venv "${FROM_NAME}"
    python -m pip freeze > "${TEMP_FILE_NAME}"
    deactivate_venv

    create_venv "${TO_NAME}"
    python -m pip install -r "${TEMP_FILE_NAME}"
    deactivate 2>/dev/null

    rm "${TEMP_FILE_NAME}"
    rm -rf "${FROM_NAME}"
}

export -f activate_found_venv
export -f create_venv
export -f rename_venv
