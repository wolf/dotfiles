command -v fzf >/dev/null || return

# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FZF_DEFAULT_OPTS='--ansi --layout=reverse'
export FZF_DEFAULT_COMMAND='fd --follow --hidden --type file --color=always'

function fze() { # fze [<pattern>] : use fzf to select one or more files in or below . whose names match <pattern> and open them in $EDITOR
    # shellcheck disable=SC2086
    fd --follow --hidden --glob --type f --color=always --print0 "$@" \
        | fzf --read0 --print0 --multi --preview-window='60%' --preview='bat --color=always --style=header,changes,grid {}' \
        | xargs -0 -o ${EDITOR}
}
