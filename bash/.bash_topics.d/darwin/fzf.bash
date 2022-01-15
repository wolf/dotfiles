function zex() { # zex [<pattern>] : use fzf to select one or more files in or below . whose names match <pattern> and open them in an existing $EDITOR
    # shellcheck disable=SC2086
    fd --follow --hidden --glob --type f --color=always --print0 "$@" \
        | fzf --read0 --print0 --multi --preview-window='60%' --preview='bat --color=always --style=header,changes,grid {}' \
        | xargs -0 -o ${EDITOR} --remote
}
