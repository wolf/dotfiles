command -v go >/dev/null 2>&1 || return

export PATH="${PATH}:$(go env GOPATH)/bin"
