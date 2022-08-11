export DOTFILES_DIR=~/brain/projects/dotfiles

function cddf() { # cddf [<relative-path>] : cd into root of the working copy of dotfiles, or to a path relative to that
    cd "${DOTFILES_DIR}/${1}" || return
}

# shellcheck disable=SC2120
function pushddf() { # pushddf [<relative-path>] : pushd combined with cddf
    pushd "${DOTFILES_DIR}/${1}" || return
}

function df_branch() { # df_branch : report what branch the dotfiles repo has currently checked out
    git -C "${DOTFILES_DIR}" branch --show-current
}

CURRENT_BRANCH="$(df_branch)"
if [[ "${CURRENT_BRANCH}" != local-only ]] && [[ "${CURRENT_BRANCH}" != dev ]] ; then
    echo "WARNING: dotfiles is not on the local-only or dev branches"
fi
