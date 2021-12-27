command -v black >/dev/null || return

function black_name() { # black_name [<pattern>] : find all the python files whose names match <pattern> in or below . and run them through black
    fd --follow --hidden --type f --extension py "$@" --exec-batch black
}

function black_since()      { since_commit "$1" | grep '\.py$' | xargs black; }     # black_since [<ref>] : like since_commit, but run found python files through black instead of list
function black_commit()     { in_commit "$1" | grep '\.py$' | xargs black; }        # black_commit [<ref>] : like in_commit, but run found python files through black instead of list
function black_dirty()      { dirty | grep '\.py$' | xargs black; }                 # black_dirty : like dirty, but run found python files through black instead of list
