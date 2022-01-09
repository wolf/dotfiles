[[ "$-" != *i* ]] && return

if [ -f /etc/bashrc ] ; then
    # shellcheck disable=SC1091
    source /etc/bashrc
fi

stty -ixon -ixoff

umask go-wx

export CDPATH=.

function show_path() { echo "${PATH}" | tr ':' '\n'; }      # show_path : display $PATH, one path per line
function show_cdpath() { echo "${CDPATH}" | tr ':' '\n'; }  # show_cdpath : display $CDPATH, one path per line

function platform() {
    local UNAME

    UNAME="$(uname)"
    UNAME="${UNAME,,}"
    if [[ ${UNAME} =~ mingw.* ]] ; then
        UNAME=mingw
    elif [[ ${UNAME} =~ cygwin.* ]] ; then
        UNAME=cygwin
    fi

    echo "${UNAME}"
}

if [ "$(command -v fdfind)" ] ; then
    alias fd=fdfind
fi

function get_topics() { # get_topics [--print0] : prints the list of topics, in order, to be executed at interactive Bash startup
    fd --follow --no-ignore --hidden "$@" --max-depth=1 --type f --regex '.*\.bash$' "${HOME}/.bash_topics.d"
    fd --follow --no-ignore --hidden "$@"               --type f --regex '.*\.bash$' "${HOME}/.bash_topics.d/$(platform)"
}

function source_all() {
    local FILE
    for FILE in "$@" ; do
        echo source "\"${FILE}\""
        # shellcheck disable=SC1090,SC2086
        source "${FILE}"
    done
}

export -f platform
export -f get_topics

function source_topics() { # source_topics : sources each of the files returned by get_topics, in order.  Does not source .bashrc
    local TOPICS
    declare -a TOPICS
    readarray -d '' TOPICS < <( get_topics --print0 )
    source_all "${TOPICS[@]}"
}

source_topics >/dev/null

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
shopt -s histappend cdspell autocd histreedit

bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

alias h20='history 20'                                              # h20 : show the last 20 entries from history
alias tree="tree -alC -I '.git|.mypy_cache|__pycache__|node_modules|*venv'"

function hosts() {  # hosts : list Hosts configured in ~/.ssh/config
    if [ -f "${HOME}/.ssh/config" ] ; then
        grep -e '^Host' "${HOME}/.ssh/config"
    fi
}

function did()  { history | grep -v 'did' | grep "$@"; }    # did <regexp> : list commands from history matching <regexp>
function mkcd() { mkdir -p "$@" && cd "${1}" || return; }   # mkcd <path> : create all directories needed to build <path> and cd into it
function be()   { sudo su -l "$@"; }                        # be <user> : start a login shell as user, but using your own sudo password
