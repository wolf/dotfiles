[ -x /usr/libexec/path_helper ] >/dev/null 2>&1 || return

# This eval modifies `$PATH`, and it makes available scripts and tools that might be used non-interactively.
# Therefore, this topic should _always_ be sourced.
eval "$(/usr/libexec/path_helper)"
