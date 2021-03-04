export DOTFILES_DIR=~/builds/dotfiles

function cddf() {
    cd "${DOTFILES_DIR}/$1"
}

function pushddf() {
    pushd "${DOTFILES_DIR}/$1"
}
