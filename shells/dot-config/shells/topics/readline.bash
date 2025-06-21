function get_readline_edit_mode() {
    set -o | (rg --color=never '(emacs|vi)\s+on' -r '$1' || echo "unknown")
}

function update_readline_edit_mode_environment_variable() {
    export READLINE_EDIT_MODE=$(get_readline_edit_mode)
}

function readline_emacs() {
    set -o emacs
}

function readline_vi() {
    set -o vi
}

alias cl-emacs=readline_emacs
alias cl-vi=readline_vi

export -f get_readline_edit_mode
