# Normally I use NeoVim.  That's set up for the general case.  But on Git Bash for Windows,
# NeoVim has troubles, so lets undo what ../nvim.bash has set up.
unalias vim

export VISUAL='vim'
export EDITOR='vim -p'
export FCEDIT='vim'

function gv() { # gv <pattern> : find matches in or below . and open them in Vim's quickfix list
    ${EDITOR} -q <(rg --follow --hidden --smart-case --vimgrep "$@") -c ':copen' -c ':bdelete 1'
}
