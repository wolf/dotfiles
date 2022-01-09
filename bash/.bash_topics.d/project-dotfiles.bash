export DOTFILES_DIR=~/builds/dotfiles

function cddf() { # cddf [<relative-path>] : cd into root of the working copy of dotfiles, or to a path relative to that
    cd "${DOTFILES_DIR}/${1}" || return
}

# shellcheck disable=SC2120
function pushddf() { # pushddf [<relative-path>] : pushd combined with cddf
    pushd "${DOTFILES_DIR}/${1}" || return
}

pushddf >/dev/null
CURRENT_BRANCH="$(git branch --show-current)"
if [[ "${CURRENT_BRANCH}" == main ]] ; then
    echo "WARNING: dotfiles is not on the local-only or dev branches"
fi
popd >/dev/null || return
