git_top_level() {
    local TOP_LEVEL
    if [[ "$(pwd)" =~ ^(.*)/.git([^[:alnum:]_]|$) ]] ; then
        TOP_LEVEL="${BASH_REMATCH[1]}"
    else
        TOP_LEVEL="$(git rev-parse --show-toplevel)"
    fi
    echo "${TOP_LEVEL}"
}
