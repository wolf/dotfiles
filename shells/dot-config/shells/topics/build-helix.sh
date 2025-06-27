# This must be sourced sometime **after** cdpath
export HELIX_BUILD_DIR="${WOLF_REPOS_DIR}/helix"
export HELIX_DEFAULT_RUNTIME="${HELIX_BUILD_DIR}/runtime"

build_helix() {
  cd ${HELIX_BUILD_DIR}
  git switch master
  git fetch --all
  git pull
  git pull upstream master
  cargo install --path helix-term --locked
}
