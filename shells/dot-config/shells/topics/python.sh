export PIP_REQUIRE_VIRTUALENV=true

function show_pythonpath() { echo "${PYTHONPATH}" | tr ':' '\n'; }      # show_pythonpath : display $PYTHONPATH, one path per line
