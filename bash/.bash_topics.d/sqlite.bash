if [ "$(command -v brew)" ] && [ -d "$(brew --prefix)/Cellar/sqlite" ] ; then
    # shellcheck disable=SC2139
    alias sqlite="$(fd '^sqlite3$' "$(brew --prefix)/Cellar/sqlite")"
fi
