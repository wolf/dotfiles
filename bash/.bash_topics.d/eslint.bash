command -v eslint >/dev/null || return
# only define eslint commands if eslint is available

function eslint_name() { # eslint_name [<pattern>] : find all the javascript files whose names match <pattern> in or below . and run them through eslint
    fd --follow --hidden --type f --extension js "$@" --exec-batch eslint
}

function eslint_since()     { since_commit "${1}" | grep '\.js$' | xargs eslint; }  # eslint_since [<ref>] : like since_commit, but run found javascript files through eslint instead of list
function eslint_commit()    { in_commit "${1}" | grep '\.js$' | xargs eslint; }     # eslint_commit [<ref>] : like in_commit, but run found javascript files through eslint instead of list
function eslint_dirty()     { dirty | grep '\.js$' | xargs eslint; }                # eslint_dirty : like dirty, but run found javascript files through eslint instead of list
