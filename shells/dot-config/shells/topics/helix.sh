command -v hx >/dev/null 2>&1 || return

export EDITOR=hx
export VISUAL=hx
export FCEDIT=hx

if command -v brew >/dev/null 2>&1 ; then
    LLVM_BIN="$(brew --prefix)/opt/llvm/bin"
    if [ -d "$LLVM_BIN" ] && [[ ":$PATH:" != *":$LLVM_BIN:"* ]] ; then
        # Yes, I'm altering `$PATH` here, but only so `hx` can see some needed tools.
        # Therefore, this topic only needs to be sourced in interactive shells.
        export PATH="${PATH}:${LLVM_BIN}"
    fi
fi
