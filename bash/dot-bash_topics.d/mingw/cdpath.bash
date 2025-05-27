# Environment variables to be used in `$CDPATH` and anywhere else that needs them.
export WOLF_REPOS_DIR="/e/develop/wolf"
export DMP_REPOS_DIR="/e/develop/dmp"

# `$PROJECTS_DIR` and `$DROPBOX_DIR` are expected to already exist
export CDPATH=.:"${WOLF_REPOS_DIR}":"${DMP_REPOS_DIR}":"${PROJECTS_DIR}":"${DROPBOX_DIR}"
