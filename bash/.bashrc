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

function in_path() { # in_path <path> : is <path> a directory in $PATH
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
    if [ -d "${HOME}/.bash_topics.d/${UNAME}" ] && [[ -n $(shopt -s nullglob; echo "${HOME}/.bash_topics.d/${UNAME}/"*.bash) ]] ; then
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

alias h20='history 20'                                              # h20 : show the last 20 entries from history
alias tree="tree -alC -I '.git|__pycache__|node_modules|*venv'"

function show_path()    { echo "${PATH}" | tr ':' '\n'; }           # show_path : display $PATH, one path per line
function hosts()        { grep -e '^Host' ~/.ssh/config; }          # hosts : list Hosts configured in ~/.ssh/config
function did()          { history | grep -v 'did' | grep "$1"; }    # did <pattern> : list commands from history matching <pattern>
function we()           { ${EDITOR} "$(which "$@")"; }              # we <script> : find <script> (using which) and open it in $EDITOR
function wll()          { ll "$(which "$1")"; }                     # wll <command> : find <command> (using which) and list it as with ls -l
function wfile()        { file "$(which "$1")"; }                   # wfile <command> : find <command> (using which) and run file on it
function mkcd()         { mkdir -p "$1" && cd "$1" || return; }     # mkcd <path> : create all directories needed to build <path> and cd into it
function resolve()      { cd "$(pwd -P)" || return; }               # resolve : if <cwd> contains any symbolic links, cd to the resolved physical directory you are actually in
