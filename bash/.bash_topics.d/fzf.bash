command -v fzf >/dev/null || return

# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FZF_DEFAULT_OPTS='--ansi'

if [ "$(command -v fd)" ] ; then
    export FZF_DEFAULT_COMMAND='fd --hidden --type file --color=always'
fi
