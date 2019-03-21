if [ $(command -v flake8) ]; then
    # only define flake8 commands if flake8 is available
    function flake8_name()      { find . -name $1 | xargs flake8; }
    function flake8_since()     { since_commit $1 | grep '\.py$' | xargs flake8; }
    function flake8_commit()    { in_commit $1 | grep '\.py$' | xargs flake8; }
    function flake8_dirty()     { dirty | grep '\.py$' | xargs flake8; }
fi
