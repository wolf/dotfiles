# shellcheck disable=SC2034

[ -f ~/builds/forgit/forgit.plugin.sh ] || return

forgit_log=zlog
forgit_diff=zdiff
forgit_add=zadd
forgit_reset_head=zreset
forgit_ignore=zbuild_ignore
forgit_checkout_file=zcheckout_file
forgit_checkout_branch=zswitch
forgit_checkout_commit=zcheckout_commit
forgit_clean=zclean
forgit_stash_show=zstash_show
forgit_cherry_pick=zcherry_pick
forgit_rebase=zrebase
forgit_fixup=zfixup

export FORGIT_FZF_DEFAULT_OPTS='--reverse'

# shellcheck disable=SC1090
source ~/builds/forgit/forgit.plugin.sh


