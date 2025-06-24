command -v node >/dev/null 2>&1 || return

# Altering `$PATH`.  This topic should be sourced whether the shell is interactive or not.
export PATH="${PATH}:./node_modules/.bin"
