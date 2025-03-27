if [ -d "${HOME}/.cargo/bin" ] && [[ ":$PATH:" != *":${HOME}/.cargo/bin:"* ]] ; then
    # If .cargo/bin is an existing direction, not yet on $PATH, then add it
    export PATH="${PATH}:${HOME}/.cargo/bin"
fi

if [ -f "${HOME}/.cargo/env" ] ; then
    # If .cargo/env is an existing file (Bash script, in this case), then source it
    source "${HOME}/.cargo/env"
fi
