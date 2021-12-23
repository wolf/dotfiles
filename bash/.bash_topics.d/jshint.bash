command -v jshint >/dev/null || return
# only define jshint commands if jshint is available

if [ "$(command -v fd)" ] ; then
    function jshint_name() {
        fd --type f --extension js --glob --follow --hidden "$@" -X jshint
    }
else
    function jshint_name() {
        find . -name "${1}" --print0 | xargs -0 jshint;
    }
fi

function jshint_since()     { since_commit "${1}" | grep '\.js$' | xargs jshint; }
function jshint_commit()    { in_commit "${1}" | grep '\.js$' | xargs jshint; }
function jshint_dirty()     { dirty | grep '\.js$' | xargs jshint; }
