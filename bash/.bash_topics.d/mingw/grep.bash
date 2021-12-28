function ge() {
    # shellcheck disable=SC2086
    grep -rl "$@" | xargs -o ${EDITOR}
}
