command -v mcfly >/dev/null || return

eval "$(mcfly init bash)"

export MCFLY_LIGHT=TRUE
export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=3
export MCFLY_RESULTS=20
