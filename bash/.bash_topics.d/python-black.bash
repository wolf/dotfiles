command -v black >/dev/null || return

function black_name() { # black_name [<pattern>] : find all the python files whose names match <pattern> in or below . and run them through black
    fd --follow --hidden --type f --extension py "$@" --exec-batch black
}

function black_dirty() { # black_dirty : like dirty, but run found python files through black instead of list
    dirty | grep '\.py$' | xargs black
}
