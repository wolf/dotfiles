[ -d "${HOME}/Library/Application Support/JetBrains/Toolbox/scripts" ] || return

# Yes, this alters `$PATH`, but the scripts it makes available are all about launching IDEs.
# Therefore, this topic only needs to be sourced in an interactive shell.
export PATH="${PATH}:${HOME}/Library/Application Support/JetBrains/Toolbox/scripts"
