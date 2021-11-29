if [ "$(command -v fd)" ] ; then
    function black_name() {
        fd --type f --extension py --glob --follow --hidden "$@" -X black
    }
else
    function black_name() {
        find . -name "$1" --print0 | xargs -0 black;
    }
fi

function black_since()      { since_commit "$1" | grep '\.py$' | xargs black; }
function black_commit()     { in_commit "$1" | grep '\.py$' | xargs black; }
function black_dirty()      { dirty | grep '\.py$' | xargs black; }
