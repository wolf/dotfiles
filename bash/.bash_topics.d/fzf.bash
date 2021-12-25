command -v fzf >/dev/null || return

# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FZF_DEFAULT_OPTS='--ansi'
export FZF_DEFAULT_COMMAND='fd --follow --hidden --type file --color=always'

function fze() {
    # shellcheck disable=SC2086
    fd --print0 --follow --hidden --type file --glob --color=always "$@" \
        | fzf --read0 --print0 --multi --preview-window='60%' --preview='bat --color=always --style=header,changes,grid {}' \
        | xargs -0 -o ${EDITOR}
}
