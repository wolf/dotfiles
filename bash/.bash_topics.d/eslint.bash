command -v eslint >/dev/null || return
# only define eslint commands if eslint is available

function eslint_name() { # eslint_name [<pattern>] : find all the javascript files whose names match <pattern> in or below . and run them through eslint
    fd --follow --hidden --type f --extension js "$@" --exec-batch eslint
}

function eslint_dirty() { # eslint_dirty : like dirty, but run found javascript files through eslint instead of list
    dirty | grep '\.js$' | xargs eslint
}
