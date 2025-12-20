build_helix() {
  rm -f $(which hx)  # on Windows, our build won't replace the existing binary

  if command -v direnv >/dev/null 2>&1; then
    direnv block "${HELIX_BUILD_DIR}/.envrc"
  fi

  cd "${HELIX_BUILD_DIR}"
  git switch master
  git fetch --all
  git pull
  git pull upstream master
  cargo install --path helix-term --locked
}
