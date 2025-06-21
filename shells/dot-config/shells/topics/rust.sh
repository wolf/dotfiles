if [ -d "${HOME}/.cargo/bin" ] ; then
    export PATH="${PATH}:${HOME}/.cargo/bin"
fi

if [ -f "${HOME}/.cargo/env" ] ; then
    # If .cargo/env is an existing file (Bash script, in this case), then source it
    source "${HOME}/.cargo/env"
fi
