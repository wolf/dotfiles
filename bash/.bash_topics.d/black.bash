function black_name()       { find . -name "$1" | xargs black; }
function black_since()      { since_commit "$1" | grep '\.py$' | xargs black; }
function black_commit()     { in_commit "$1" | grep '\.py$' | xargs black; }
function black_dirty()      { dirty | grep '\.py$' | xargs black; }
