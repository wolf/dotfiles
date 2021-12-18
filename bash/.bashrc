export CDPATH=.

[[ "$-" != *i* ]] && return

if [ -f /etc/bashrc ] ; then
    source /etc/bashrc
fi

stty -ixon -ixoff

if [ "$(command -v exa)" ] ; then
    alias ls=exa
    alias ll="exa -Fal"
    alias lgit="exa -Fal --tree --git --ignore-glob '.git' --icons"
else
    alias ls="command ls --color"
    alias ll="ls -Falh --color"
fi

if [ "$(command -v tree)" ] && [ ! "$(command -v fd)" ] && [ ! "$(command -v as-tree)" ] ; then
    alias tree="tree -alC -I '.git|__pycache__|node_modules|*.venv'"
fi

alias grep='grep --color'
alias h20='history 20'

export EDITOR='vim'

function present_in_path() {
    echo "${PATH}" | tr ':' '\n' | grep -e "^$1$" >/dev/null;
}

if [[ -d ~/.bash_topics.d ]]; then
    for TOPIC in ~/.bash_topics.d/*.bash; do
        if [[ ! "${TOPIC}" =~ ~/.bash_topics.d/~.* ]] ; then
            source "${TOPIC}"
        fi
    done
fi

if [ ! $(command -v f) ] ; then
    function f() {
        # usage: f <name> [...]
        # example: f Makefile
        # example: f Makefile -type f
        # find the filesystem object with the given name
        find . -name "$@" 2>/dev/null
    }
fi

umask go-wx

if [[ -f ~/.dir_colors ]]; then
    eval $(dircolors -b ~/.dir_colors)
fi

if command -v brew >/dev/null && test -f $(brew --prefix)/etc/bash_completion ; then
    source "$(brew --prefix)"/etc/bash_completion
elif [ -f /etc/bash_completion ] ; then
    source /etc/bash_completion
fi

if command -v __git_ps1 >/dev/null; then
    export PS1='\n\u@\h:\[\e[35m\]\w\[\e[0m\]$(virtualenv_info) $(__git_ps1 "\[\e[32m\][$(time_since_last_commit) %s $(tip)]\[\e[0m\]")'$'\n\$ '
else
    export PS1='\n\u@\h:\[\e[35m\]\w\[\e[0m\]$(virtualenv_info)'$'\n\$ '
fi

export SUDO_PS1='\n\u@\h:\[\e[35m\]\w\[\e[0m\]\n\$ '

export HISTSIZE=10000
export HISTIGNORE="&:ls:[bf]g:exit:history:h20:..:pwd:ll:did"
shopt -s histappend cdspell autocd

function did() { history | grep -v 'did' | grep "$1"; }

bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

if [ ! "$(command -v fx)" ] ; then
    function fx() {
        find . -name "$@" -print0 2>/dev/null | xargs -0 ls --color -Falhd
    }
fi

if [ ! "$(command -v fcd)" ] ; then
    function fcd() {
        # usage: fcd <pattern>
        # example: fcd js
        # find the directory with the given name, cd-ing into the first match found
        FIRST_MATCHING_DIRECTORY="$(find . -type d -name "$@" 2>/dev/null | head -n 1)"
        if [ -d "${FIRST_MATCHING_DIRECTORY}" ]; then
            cd "${FIRST_MATCHING_DIRECTORY}" || return
        fi
    }
fi

function show_path() {
    echo "${PATH}" | tr ':' '\n'
}

function hosts() {
    grep -e '^Host' ~/.ssh/config
}

if [ ! "$(command -v en)" ] ; then
    function en() {
        find . -type f -print0 -name "$1" 2>/dev/null | xargs -0 "${EDITOR}"
    }
fi

function ew()   { $EDITOR "$(which "$@")"; }
function lw()   { ll "$(which "$1")"; }
function filew(){ file "$(which "$1")"; }
function mkcd() { mkdir -p "$1" && cd "$1" || return; }
function resolve() { cd "$(pwd -P)" || return; }
function psg()  { ps ax | grep -v grep | grep "$1"; }

if [ -f /opt/homebrew/etc/xml/catalog ]; then
    export XML_CATALOG_FILES=/opt/homebrew/etc/xml/catalog
fi

function help_wolf() {
    echo 'did pattern       -- find pattern in history'
    echo
    echo 'f pattern         -- find pattern in or below .'
    echo 'fx pattern        -- ls -l all the files that match pattern in or below .'
    echo 'fcd pattern       -- cd to the first directory that matches pattern in or below .'
    echo 'en pattern        -- find and edit the files that match pattern in or below .'
    echo 'ew script         -- find and edit the file matching script along $PATH'
    echo 'lw command        -- ls -l the file matching command along $PATH'
    echo 'filew command     -- run `file` on the file matching command along $PATH'
    echo 'mkcd path         -- create a directory (and all intervening directories) and cd into it'
    echo 'resolve           -- make the logical current directory match the physical one'
    echo 'psg pattern       -- grep with ps for the given pattern'
}
