# Environment variables to be used in `$CDPATH` and anywhere else that needs them.
export REPOS_DIR="${HOME}/develop"
export WOLF_REPOS_DIR="${REPOS_DIR}/wolf"
export DMP_REPOS_DIR="${REPOS_DIR}/dmp"
export DROPBOX_DIR="${HOME}/Dropbox"
export PROJECTS_DIR="${DROPBOX_DIR}/projects"
export DOTFILES_DIR="${WOLF_REPOS_DIR}/dotfiles"

# This is for typing directory names at the prompt, therefore, this topic only needs to be sourced for,
# interactive shells.
export CDPATH=.:"${WOLF_REPOS_DIR}":"${DMP_REPOS_DIR}":"${REPOS_DIR}":"${PROJECTS_DIR}":"${DROPBOX_DIR}"

show_cdpath() { echo "${CDPATH}" | tr ':' '\n'; }  # show_cdpath : display `$CDPATH`, one path per line
