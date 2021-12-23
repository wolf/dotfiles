command -v go >/dev/null || return

export GOPATH=~/work/go
export PATH="${PATH}:${GOPATH}/bin"
