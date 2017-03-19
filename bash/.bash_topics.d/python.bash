if [ $(command -v pyflakes) ]; then
    # only define pyflakes commands if pyflakes is available
    function pyflakes_name()    { find . -name $1 | xargs pyflakes; }
    function pyflakes_since()   { since_commit $1 | grep '\.py$' | xargs pyflakes; }
    function pyflakes_commit()  { in_commit $1 | grep '\.py$' | xargs pyflakes; }
    function pyflakes_dirty()   { dirty | grep '\.py$' | xargs pyflakes; }
fi

if [ $(command -v pylint) ]; then
    # only define pylint commands if pylint is available
    function pylint_name()      { find . -name $1 | xargs pylint; }
    function pylint_since()     { since_commit $1 | grep '\.py$' | xargs pylint; }
    function pylint_commit()    { in_commit $1 | grep '\.py$' | xargs pylint; }
    function pylint_dirty()     { dirty | grep '\.py$' | xargs pylint; }
fi
