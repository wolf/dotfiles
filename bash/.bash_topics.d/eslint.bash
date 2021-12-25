command -v eslint >/dev/null || return
# only define eslint commands if eslint is available

function eslint_name() {
    fd --type f --extension js --glob --follow --hidden "$@" -X eslint
}

function eslint_since()     { since_commit "${1}" | grep '\.js$' | xargs eslint; }
function eslint_commit()    { in_commit "${1}" | grep '\.js$' | xargs eslint; }
function eslint_dirty()     { dirty | grep '\.js$' | xargs eslint; }
