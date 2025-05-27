# Environment variables to be used in `$CDPATH` and anywhere else that needs them.
export WOLF_REPOS_DIR="~/develop/wolf"
export DMP_REPOS_DIR="~/develop/dmp"
export DROPBOX_DIR="${HOME}/Dropbox"
export PROJECTS_DIR="${DROPBOX_DIR}/projects"

export CDPATH=.:"${WOLF_REPOS_DIR}":"${DMP_REPOS_DIR}":"${PROJECTS_DIR}":"${DROPBOX_DIR}"

function show_cdpath() { echo "${CDPATH}" | tr ':' '\n'; }  # show_cdpath : display $CDPATH, one path per line
