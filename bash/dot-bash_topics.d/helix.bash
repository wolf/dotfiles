export EDITOR=hx
export VISUAL=hx
export FCEDIT=hx

if command -v brew >/dev/null ; then
    local LLVM_BIN="$(brew --prefix)/opt/llvm/bin"
    if [ -d "$LLVM_BIN" ] && [[ ":$PATH:" != *":$LLVM_BIN:"* ]] ; then
        export PATH="${PATH}:${LLVM_BIN}"
    fi
fi

# For building Helix myself
export HELIX_RUNTIME="~/.config/helix/runtime"
