# This is for typing directory names at the prompt, therefore, this topic only needs to be sourced for,
# interactive shells.
CDPATH=.\
:"${WOLF_REPOS_DIR}"\
:"${DMP_REPOS_DIR}"\
:"${REPOS_DIR}"\
:"${OBSIDIAN_VAULTS_DIR}"

show_cdpath() { echo "${CDPATH}" | tr ':' '\n'; }  # show_cdpath : display `$CDPATH`, one path per line
