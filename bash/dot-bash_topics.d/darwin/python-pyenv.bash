command -v pyenv >/dev/null || return

export PYTHON_CONFIGURE_OPTS="--enable-framework"
export LDFLAGS="-L/opt/homebrew/lib"
export CPPFLAGS="-I/opt/homebrew/include"
