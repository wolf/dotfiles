command -v pixi >/dev/null 2>&1 || return

eval "$(pixi completion --shell bash)"
