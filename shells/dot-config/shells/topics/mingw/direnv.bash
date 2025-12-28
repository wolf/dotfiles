command -v direnv >/dev/null 2>&1 || return

export _unmangle_direnv_names='PATH PYTHONPATH'
_unmangle_direnv_paths() {
  for k in $_unmangle_direnv_names; do
    if [[ -n ${!k} ]]; then
      eval "$k=\"\$(/usr/bin/cygpath -p \"\$$k\")\""
    fi
  done
}

eval "$(direnv hook bash | sed -e 's@export bash)@export bash) _unmangle_direnv_paths@')"
