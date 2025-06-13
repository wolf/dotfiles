# requires cdpath.sh is sourced _before_ sourcing this file: we need `$DOTFILES_DIR`

cddf() { # cddf [<relative-path>] : cd into root of the working copy of dotfiles, or to a path relative to that
    cd "${DOTFILES_DIR}/${1}" || return
}

# shellcheck disable=SC2120
pushddf() { # pushddf [<relative-path>] : pushd combined with cddf
    pushd "${DOTFILES_DIR}/${1}" || return
}

df_branch() { # df_branch : report what branch the dotfiles repo has currently checked out
    git -C "${DOTFILES_DIR}" branch --show-current
}

CURRENT_BRANCH="$(df_branch)"
if [[ "${CURRENT_BRANCH}" != local-only ]] ; then
    echo "WARNING: dotfiles is not on the local-only branch" >&2
fi
