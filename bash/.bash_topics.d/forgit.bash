# shellcheck disable=SC2034

[ -f ~/builds/forgit/forgit.plugin.sh ] || return

export FORGIT_FZF_DEFAULT_OPTS='--reverse'

# shellcheck disable=SC1090
source ~/builds/forgit/forgit.plugin.sh

export PATH="${PATH}:${FORGIT_INSTALL_DIR}/bin"
