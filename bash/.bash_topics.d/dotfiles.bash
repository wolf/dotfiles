export DOTFILES_DIR=~/builds/dotfiles

function cddf() { # cddf [<relative-path>] : cd into root of the working copy of dotfiles, or to a path relative to that
    cd "${DOTFILES_DIR}/${1}" || return
}

# shellcheck disable=SC2120
function pushddf() { # pushddf [<relative-path>] : pushd combined with cddf
    pushd "${DOTFILES_DIR}/${1}" || return
}

pushddf >/dev/null
if [[ $(git branch --show-current) != local-only ]] ; then
    echo "WARNING: dotfiles is not on the local-only branch"
fi
popd >/dev/null || return
