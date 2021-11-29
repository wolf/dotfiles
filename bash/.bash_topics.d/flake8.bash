if [ "$(command -v flake8)" ]; then
    # only define flake8 commands if flake8 is available

    if [ "$(command -v fd)" ] ; then
        function flake8_name() {
            fd --type f --extension py --glob --follow --hidden "$@" -X flake8
        }
    else
        function flake8_name() {
            find . -name "$1" --print0 | xargs -0 flake8;
        }
    fi

    function flake8_since()     { since_commit "$1" | grep '\.py$' | xargs flake8; }
    function flake8_commit()    { in_commit "$1" | grep '\.py$' | xargs flake8; }
    function flake8_dirty()     { dirty | grep '\.py$' | xargs flake8; }
fi
