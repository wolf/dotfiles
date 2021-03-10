export DOTFILES_DIR=~/builds/dotfiles

function cddf() {
    cd "${DOTFILES_DIR}/$1"
}

function pushddf() {
    pushd "${DOTFILES_DIR}/$1"
}

pushddf >/dev/null
if [[ $(git branch --show-current) != local-only ]] ; then
    echo "WARNING: dotfiles is not on the local-only branch"
fi
popd >/dev/null
