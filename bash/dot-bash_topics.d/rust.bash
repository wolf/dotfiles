command -v rustc >/dev/null || return

export PATH="${PATH}":~/.cargo/bin
source "${HOME}/.cargo/env"
