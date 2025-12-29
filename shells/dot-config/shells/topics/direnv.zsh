command -v direnv >/dev/null 2>&1 || return

eval "$(direnv hook zsh)"
export DIRENV_LOG_FORMAT=""
