command -v flake8 >/dev/null || return

function flake8_name() { # flake8_name [<pattern>] : find all the python files whose names match <pattern> in or below . and run them through flake8
    fd --follow --hidden --type f --extension py "$@" --exec-batch flake8
}

function flake8_since()     { since_commit "${1}" | grep '\.py$' | xargs flake8; }  # flake8_since [<ref>] : like since_commit, but run found python files through flake8 instead of list
function flake8_commit()    { in_commit "${1}" | grep '\.py$' | xargs flake8; }     # flake8_commit [<ref>] : like in_commit, but run found python files through flake8 instead of list
function flake8_dirty()     { dirty | grep '\.py$' | xargs flake8; }                # flake8_dirty : like dirty, but run found python files through flake8 instead of list
