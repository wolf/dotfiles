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

if [ -d "${HOME}/.bash_topics.d" ] ; then
    for TOPIC in "${HOME}/.bash_topics.d/"*.bash ; do
        # shellcheck disable=SC1090
        source "${TOPIC}"
    done

    UNAME="$(uname)"
    UNAME="${UNAME,,}"
    if [[ ${UNAME} =~ msys.* ]] ; then
        UNAME=msys
    elif [[ ${UNAME} =~ cygwin.* ]] ; then
        UNAME=cygwin
    fi
    if [ -d "${HOME}/.bash_topics.d/${UNAME}" ] ; then
        for TOPIC in "${HOME}/.bash_topics.d/${UNAME}/"*.bash ; do
            # shellcheck disable=SC1090
            source "${TOPIC}"
        done
    fi
fi

if [ -f ~/.dir_colors ] ; then
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
alias tree="tree -alC -I '.git|__pycache__|node_modules|*venv'"

function show_path()    { echo "${PATH}" | tr ':' '\n'; }
function hosts()        { grep -e '^Host' ~/.ssh/config; }
function did()          { history | grep -v 'did' | grep "$1"; }
function we()           { ${EDITOR} "$(which "$@")"; }
function wll()          { ll "$(which "$1")"; }
function wfile()        { file "$(which "$1")"; }
function mkcd()         { mkdir -p "$1" && cd "$1" || return; }
function resolve()      { cd "$(pwd -P)" || return; }

function help_wolf() {
    echo 'did pattern       -- find pattern in history'
    echo
    echo 'f pattern         -- find all the filesystem objects that match the pattern in or below .'
    echo 'fll pattern       -- ls -l all the files that match pattern in or below .'
    echo 'fcd pattern       -- cd to the first directory that matches pattern in or below .'
    echo 'fcat pattern      -- cat all the filesystem objects that match the pattern in or below .'
    echo 'fe pattern        -- find and edit all the files that match pattern in or below .'
    echo 'ge pattern        -- grep for pattern and edit all the files with matches in or below .'
    # shellcheck disable=SC2016
    echo 'we script         -- find (with which) and edit the script along $PATH'
    # shellcheck disable=SC2016
    echo 'wll pattern       -- ls -l the filesystem objects matching pattern along $PATH'
    # shellcheck disable=SC2016
    echo 'wfile command     -- run `file` on the file matching command along $PATH'
    echo 'mkcd path         -- create a directory (and all intervening directories) and cd into it'
    echo 'resolve           -- make the logical current directory match the physical one'
}
