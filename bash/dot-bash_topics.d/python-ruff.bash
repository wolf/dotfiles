command -v ruff >/dev/null || return

function ruff_name() { # ruff_name [<pattern>] : find all the python files whose names match <pattern> in or below . and run them through ruff
    fd --follow --hidden --type f --extension py "$@" --exec-batch ruff
}

function ruff_dirty() { # ruff_dirty : like dirty, but run found python files through ruff instead of list
    dirty | grep '\.py$' | xargs ruff
}
