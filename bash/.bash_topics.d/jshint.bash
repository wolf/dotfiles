if [ $(command -v jshint) ]; then
    # only define jshint commands if jshint is available
    function jshint_name()      { find . -name $1 | xargs jshint; }
    function jshint_since()     { since_commit $1 | grep '\.js$' | xargs jshint; }
    function jshint_commit()    { in_commit $1 | grep '\.js$' | xargs jshint; }
    function jshint_dirty()     { dirty | grep '\.js$' | xargs jshint; }
fi
