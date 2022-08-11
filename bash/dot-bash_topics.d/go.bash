command -v go >/dev/null || return

export GOPATH=/Volumes/Mercury/resources/go
export PATH="${PATH}:${GOPATH}/bin"
