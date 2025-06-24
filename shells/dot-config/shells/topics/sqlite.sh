command -v brew >/dev/null 2>&1 && [ -d "$(brew --prefix)/Cellar/sqlite" ] || return

# shellcheck disable=SC2139
alias sqlite="$(fd '^sqlite3$' "$(brew --prefix)/Cellar/sqlite")"
