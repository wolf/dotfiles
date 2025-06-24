command -v tree >/dev/null 2>&1 || return

# TODO: only alias if `tree` is available.
alias tree="tree -alC -I '.git|*venv|__pycache__|.pytest_cache|.mypy_cache|.pixi|target|node_modules'"
