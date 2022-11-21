command -v go >/dev/null || return

export GOPATH=~/brain/resources/go
export PATH="${PATH}:${GOPATH}/bin"
