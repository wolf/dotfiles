git_top_level() {
    local TOP_LEVEL
    if [[ "$(pwd)" =~ ^(.*)/.git([^[:alnum:]_]|$) ]] ; then
        TOP_LEVEL="${match[1]}"
    else
        TOP_LEVEL="$(git rev-parse --show-toplevel)"
    fi
    echo "${TOP_LEVEL}"
}
