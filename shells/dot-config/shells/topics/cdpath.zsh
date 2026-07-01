cdpath=( . "$WOLF_REPOS_DIR" "$DMP_REPOS_DIR" "$REPOS_DIR" "$OBSIDIAN_VAULTS_DIR" )

zstyle ':completion:*:cd:*' tag-order local-directories path-directories

show_cdpath() { printf '%s\n' "${cdpath[@]}"; }
