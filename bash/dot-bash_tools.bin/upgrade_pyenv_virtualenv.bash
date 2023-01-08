#/usr/bin/env -S bash -i

# https://pypi.org/project/pipdeptree/

# Usage: upgrade_pyenv_virtualenv.bash VIRTUALENV_NAME [PYTHON_VERSION] [PIN]

eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# get the name of the virtual env to update
VIRTUALENV="${1}"
REQUIREMENTS_FILE="${VIRTUALENV}_requirements.txt"

# get the version of python to use
PYTHON_VERSION=
if [[ $# -ge 2 ]]; then
    PYTHON_VERSION="${2}"
fi

# activate the existing virtual env
pyenv activate "${VIRTUALENV}"

# install pipdeptree
python -m pip install --upgrade pipdeptree

# run pipdeptree and get just the top-level packages
# subtract pip, pipdeptree, setuptools, and wheel
python -m pipdeptree -f --warn silence | rg '^[a-zA-Z0-9\-]+' | rg -v '^(pip|pipdeptree|setuptools|wheel)=' | sort -u > "${REQUIREMENTS_FILE}"

# if not pinning, remove the version numbers
if [[ $# -lt 3 ]]; then
    TEMP_FILE="$$_temp.txt"
    cat "${REQUIREMENTS_FILE}" | rg '^(\w+)=.*$' --replace '$1' > "${TEMP_FILE}"
    cat "${REQUIREMENTS_FILE}" | rg '^-e ' >> "${TEMP_FILE}"
    mv "${TEMP_FILE}" "${REQUIREMENTS_FILE}"
fi

# deactivate the virtual environment
pyenv deactivate

# destroy the existing virtual environment
pyenv virtualenv-delete -f "${VIRTUALENV}"

# create a new virtual environment with the saved name
pyenv virtualenv ${PYTHON_VERSION} "${VIRTUALENV}"

# activate the new virtual environment
pyenv activate "${VIRTUALENV}"

# install pip, setuptools, and wheel
python -m pip install --upgrade pip setuptools wheel

# install everything from requirements.txt
python -m pip install -r "${REQUIREMENTS_FILE}"

# deactivate the virtual environment
pyenv deactivate

# delete requirements.txt
rm "${REQUIREMENTS_FILE}"
