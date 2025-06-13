[ -d /opt/homebrew/opt/gnu-sed/libexec/gnubin ] || return

# `sed` might be run non-interactively, therefore, this topic should _always_ be sourced.
PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
