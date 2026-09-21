# This must be sourced sometime **after** cdpath
export HELIX_BUILD_DIR="${THIRDPARTY_REPOS_DIR}/helix-with-steel"
export HELIX_DEFAULT_RUNTIME="${HELIX_BUILD_DIR}/runtime"

build-helix() {
  # Might not be there, might not be `$(which hx)`, might be `hx.exe` (need to check that works)
  rm -f "~/.cargo/bin/hx{,.exe}"

  if command -v direnv >/dev/null 2>&1; then
    direnv block "${HELIX_BUILD_DIR}/.envrc"
  fi

  cd "${HELIX_BUILD_DIR}"
  git switch steel-event-system
  git fetch --all
  git pull
  git pull upstream steel-event-system
  cargo xtask steel

  hx --grammar fetch
  hx --grammar build
}
