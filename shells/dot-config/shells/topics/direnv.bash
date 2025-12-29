command -v direnv >/dev/null 2>&1 || return

eval "$(direnv hook bash)"
export DIRENV_LOG_FORMAT=""
