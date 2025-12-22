# This must be sourced sometime **after** cdpath
export HELIX_BUILD_DIR="${WOLF_REPOS_DIR}/helix"
export HELIX_DEFAULT_RUNTIME="${HELIX_BUILD_DIR}/runtime"

build_helix() {
  rm -f "$(which hx)"

  if command -v direnv >/dev/null 2>&1; then
    direnv block "${HELIX_BUILD_DIR}/.envrc"
  fi

  cd "${HELIX_BUILD_DIR}"
  git switch master
  git fetch --all
  git pull
  git pull upstream master
  cargo install --path helix-term --locked

  hx --grammar fetch
  hx --grammar build
}
