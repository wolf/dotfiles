# shellcheck disable=SC2034

[ -f ~/brain/resources/forgit/forgit.plugin.zsh ] || return

export FORGIT_FZF_DEFAULT_OPTS='--reverse'

# shellcheck disable=SC1090
source ~/brain/resources/forgit/forgit.plugin.zsh

export PATH="${PATH}:${FORGIT_INSTALL_DIR}/bin"
