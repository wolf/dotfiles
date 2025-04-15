export DMP_DIR="${HOME}/development/DMP"
export DMP_REPOS_DIR="${DMP_DIR}/repos"

export DOTFILES_DIR="${HOME}/dotfiles"

export DROPBOX_DIR="${HOME}/Dropbox"
export PROJECTS_DIR="${DROPBOX_DIR}/projects"
export SRC_DIR="${HOME}/src"

export CDPATH=.:"${DMP_REPOS_DIR}":"${SRC_DIR}":"${DOTFILES_DIR}":"${PROJECTS_DIR}":"${DROPBOX_DIR}"

function show_cdpath() { echo "${CDPATH}" | tr ':' '\n'; }  # show_cdpath : display $CDPATH, one path per line


