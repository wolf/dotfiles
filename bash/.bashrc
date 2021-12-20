export CDPATH=.

[[ "$-" != *i* ]] && return

if [ -f /etc/bashrc ] ; then
    # shellcheck disable=SC1091
    source /etc/bashrc
fi

stty -ixon -ixoff

umask go-wx

export EDITOR='vim'
export FCEDIT='vim'

function present_in_path() {
    echo "${PATH}" | tr ':' '\n' | grep -e "^$1$" >/dev/null;
}

if [[ -d ~/.bash_topics.d ]]; then
    for TOPIC in ~/.bash_topics.d/*.bash; do
        # shellcheck disable=SC1090
        source "${TOPIC}"
    done
fi

if [[ -f ~/.dir_colors ]]; then
    # shellcheck disable=SC2046
    eval $(dircolors -b ~/.dir_colors)
fi

if command -v brew >/dev/null && test -f "$(brew --prefix)/etc/bash_completion" ; then
    # shellcheck disable=SC1091
    source "$(brew --prefix)"/etc/bash_completion
elif [ -f /etc/bash_completion ] ; then
    # shellcheck disable=SC1091
    source /etc/bash_completion
fi

if command -v __git_ps1 >/dev/null ; then
    export PS1='\n\u@\h:\[\e[35m\]\w\[\e[0m\]$(virtualenv_info) $(__git_ps1 "\[\e[32m\][$(time_since_last_commit) %s $(tip)]\[\e[0m\]")'$'\n\$ '
else
    export PS1='\n\u@\h:\[\e[35m\]\w\[\e[0m\]$(virtualenv_info)'$'\n\$ '
fi

export SUDO_PS1='\n\u@\h:\[\e[35m\]\w\[\e[0m\]\n\$ '

export HISTSIZE=10000
export HISTIGNORE="&:ls:[bf]g:exit:history:h20:..:pwd:ll:did"
shopt -s histappend cdspell autocd

bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

alias h20='history 20'
alias grep='grep --color'

if [ ! "$(alias ls 2>/dev/null)" ] ; then
    # shellcheck disable=SC2032
    alias ls="command ls --color"
    alias ll="ls -Falh --color"
fi

if [ "$(command -v tree)" ] && [ ! "$(command -v fd)" ] && [ ! "$(command -v as-tree)" ] ; then
    alias tree="tree -alC -I '.git|__pycache__|node_modules|*.venv'"
fi

if [ ! "$(command -v f)" ] ; then
    # first check: is f already defined?  If so, maybe it was created by an active topic
    # similarly check in each of the following commands as well

    function f() {
        # "find..."
        # usage: f <name> [...]
        # example: f Makefile
        # example: f Makefile -type f
        # find the filesystem object with the given name
        find . -name "$@" 2>/dev/null
    }
fi

if [ ! "$(command -v fx)" ] ; then
    function fx() {
        # "find and list files in long format"
        # usage: fx <pattern>
        # example: fx '*.bash'
        # find the filesystem objects matching the given pattern in or below .

        # shellcheck disable=SC2033
        find . -name "$@" -print0 2>/dev/null | xargs -0 ls --color -Falhd
    }
fi

if [ ! "$(command -v fcd)" ] ; then
    function fcd() {
        # "find and cd into..."
        # usage: fcd <pattern>
        # example: fcd js
        # find the directory with the given name, cd-ing into the first match found
        FIRST_MATCHING_DIRECTORY="$(find . -type d -name "$@" 2>/dev/null | head -n 1)"
        if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
            cd "${FIRST_MATCHING_DIRECTORY}" || return
        fi
    }
fi

if [ ! "$(command -v en)" ] ; then
    function en() {
        # "edit by name"
        # usage: en <name>
        # example: en .bashrc
        # find the files with the given name in or below . and open them in the default editor
        find . -type f -print0 -name "$1" 2>/dev/null | xargs -0 ${EDITOR}
    }
fi

function show_path()    { echo "${PATH}" | tr ':' '\n'; }
function hosts()        { grep -e '^Host' ~/.ssh/config; }
function did()          { history | grep -v 'did' | grep "$1"; }
function ew()           { ${EDITOR} "$(which "$@")"; }
function lw()           { ll "$(which "$1")"; }
function filew()        { file "$(which "$1")"; }
function mkcd()         { mkdir -p "$1" && cd "$1" || return; }
function resolve()      { cd "$(pwd -P)" || return; }

function help_wolf() {
    echo 'did pattern       -- find pattern in history'
    echo
    echo 'f pattern         -- find pattern in or below .'
    echo 'fx pattern        -- ls -l all the files that match pattern in or below .'
    echo 'fcd pattern       -- cd to the first directory that matches pattern in or below .'
    echo 'en pattern        -- find and edit the files that match pattern in or below .'
    # shellcheck disable=SC2016
    echo 'ew script         -- find and edit the file matching script along $PATH'
    # shellcheck disable=SC2016
    echo 'lw command        -- ls -l the file matching command along $PATH'
    # shellcheck disable=SC2016
    echo 'filew command     -- run `file` on the file matching command along $PATH'
    echo 'mkcd path         -- create a directory (and all intervening directories) and cd into it'
    echo 'resolve           -- make the logical current directory match the physical one'
}
