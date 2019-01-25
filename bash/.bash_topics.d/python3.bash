alias black='python3 -m black'

function black_name()       { find . -name "$1" | xargs python3 -m black; }
function black_since()      { since_commit "$1" | grep '\.py$' | xargs python3 -m black; }
function black_commit()     { in_commit "$1" | grep '\.py$' | xargs python3 -m black; }
function black_dirty()      { dirty | grep '\.py$' | xargs python3 -m black; }
