command -v black >/dev/null || return

function black_name() {
    fd --type f --extension py --glob --follow --hidden "$@" -X black
}

function black_since()      { since_commit "$1" | grep '\.py$' | xargs black; }
function black_commit()     { in_commit "$1" | grep '\.py$' | xargs black; }
function black_dirty()      { dirty | grep '\.py$' | xargs black; }
