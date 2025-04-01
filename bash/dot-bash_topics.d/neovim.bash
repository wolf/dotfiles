# export VISUAL='nvim'
# export EDITOR='nvim -p'
# export FCEDIT='nvim'

alias vim='nvim -p'

function gv() { # gv <pattern> : find matches in or below . and open them in NeoVim's quickfix list
    ${EDITOR} -q <(rg --follow --hidden --smart-case --vimgrep "$@") -c ':copen' -c ':bdelete 1'
}
