command -v pyenv >/dev/null || return

export PYENV_ROOT="${HOME}/.pyenv"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
