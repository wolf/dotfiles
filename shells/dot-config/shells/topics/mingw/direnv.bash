command -v direnv >/dev/null 2>&1 || return

# Started from the solution I found at: https://eighty-twenty.org/2024/01/04/direnv-path-unmangling-on-windows

export _unmangle_direnv_names='PATH PYTHONPATH'
_unmangle_direnv_paths() {
  for k in $_unmangle_direnv_names; do
    if [[ -n ${!k} ]]; then
      eval "$k=\"\$(/usr/bin/cygpath -p \"\$$k\")\""
    fi
  done
}

eval "$(direnv hook bash | sed -e 's@export bash)@export bash) _unmangle_direnv_paths@')"
