export PATH=/usr/local/bin:${PATH}

[[ "$-" != *i* ]] && return

if [ -f /etc/bashrc ] ; then
    source /etc/bashrc
fi

stty -ixon -ixoff

if ls --color >/dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag=-G
fi

alias ls="command ls ${colorflag}"
alias ll="ls -Falh ${colorflag}"
alias grep='grep --color'
alias h20='history 20'

export EDITOR='vim'

function present_in_path() {
    echo $PATH | tr ':' '\n' | grep -e "^$1$" >/dev/null;
}

if [[ -d ~/.bash_topics.d ]]; then
    for topic in ~/.bash_topics.d/*; do
        if [[ ! ${topic} =~ ~/.bash_topics.d/~.* ]] ; then
            source ${topic}
        fi
    done
fi

if [ "$(command -v fd)" ] && [ "$(command -v as-tree)" ] ; then
    function tree() {
        TARGET_DIR=${1:-.}
        PATTERN=${2:-.}
        # Note the reversal.  This is the opposite of how fd normally works.
        fd --follow --hidden "${PATTERN}" "${TARGET_DIR}" | as-tree
    }
else
    alias tree="tree -alC -I '.git|__pycache__|node_modules|*.venv'"
fi

umask go-wx

if [[ -f ~/.dir_colors ]]; then
    eval $(dircolors -b ~/.dir_colors)
fi

if command -v brew >/dev/null && test -f $(brew --prefix)/etc/bash_completion ; then
    source $(brew --prefix)/etc/bash_completion
elif [ -f /etc/bash_completion ] ; then
    source /etc/bash_completion
else
    if [ -f ~/.git-completion.bash ] ; then
        source ~/.git-completion.bash
    fi
    if [ -f ~/.git-prompt.sh ] ; then
        source ~/.git-prompt.sh
    fi
fi

if [ $(uname) = 'Darwin' ] ; then # if I'm on macOS...

    if [ -z "${SSH_CONNECTION}" ] ; then
        alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
    fi

fi

export VIRTUAL_ENV_DISABLE_PROMPT=1

function tip() {
    branch=${1:-HEAD}
    git rev-parse --short $branch 2>/dev/null;
}
function time_since_last_commit { git log --no-walk --format="%ar" 2>/dev/null | sed 's/\([0-9]\) \(.\).*/\1\2/'; }
function virtualenv_info()      { [ $VIRTUAL_ENV ] && echo ' ('$(basename $VIRTUAL_ENV)')'; }

# used to reattach ssh forwarding to "stale" tmux sessions
# http://justinchouinard.com/blog/2010/04/10/fix-stale-ssh-environment-variables-in-gnu-screen-and-tmux/
function refresh_ssh() {
    if [[ -n $TMUX ]]; then
        NEW_SSH_AUTH_SOCK=$(tmux showenv | grep ^SSH_AUTH_SOCK | cut -d = -f 2)
        if [[ -n $NEW_SSH_AUTH_SOCK ]] && [[ -S $NEW_SSH_AUTH_SOCK ]]; then
            SSH_AUTH_SOCK=$NEW_SSH_AUTH_SOCK
        fi
    fi
}

if command -v __git_ps1 >/dev/null; then
    export PS1='\n\u@\h:\[\e[35m\]\w\[\e[0m\]$(virtualenv_info) $(__git_ps1 "\[\e[32m\][$(time_since_last_commit) %s $(tip)]\[\e[0m\]")'$'\n$ '
else
    export PS1='\n\u@\h:\[\e[35m\]\w\[\e[0m\]$(virtualenv_info)'$'\n$ '
fi

export HISTSIZE=10000
export HISTIGNORE="&:ls:[bf]g:exit:history:h20:..:pwd:ll:did"
shopt -s histappend cdspell autocd

function did() { history | grep -v 'did' | grep "$1"; }

bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

function f() {
    # usage: f <name> [...]
    # example: f Makefile
    # example: f Makefile -type f
    # find the filesystem object with the given name
    find . -name "$@" 2>/dev/null
}

function fx() {
    find . -name "$@" 2>/dev/null | xargs ls ${colorflag} -Falhd
}

function fcd() {
    # usage: fcd <directory_basename>
    # example: fcd js
    # find the directory with the given name, cd-ing into the first match found
    cd "$(find . -type d -name "$@" 2>/dev/null | awk "BEGIN { getline; print }")"
}

function show_path() {
    echo ${PATH} | tr ':' '\n'
}

function hosts() {
    grep -e '^Host' ~/.ssh/config
}

function en()   { $EDITOR $(find . -type f -name "$@" 2>/dev/null); }
function ew()   { $EDITOR "$(which "$@")"; }
function lw()   { ll "$(which "$1")"; }
function mkcd() { mkdir -p "$1" && cd "$1"; }
function resolve() { cd $(pwd -P); }
function psg()  { ps ax | grep -v grep | grep "$1"; }

export XML_CATALOG_FILES=/usr/local/etc/xml/catalog

function help_wolf() {
    echo 'did pattern       -- find pattern in history'
    echo
    echo 'f pattern         -- find pattern in or below .'
    echo 'fx pattern        -- ls -l all the files that match pattern in or below .'
    echo 'fcd pattern       -- cd to the first directory that matches pattern in or below .'
    echo 'en pattern        -- find and edit the files that match pattern in or below .'
    echo 'ew script         -- find and edit the file matching script along $PATH'
    echo 'lw command        -- ls -l the file matching command along $PATH'
    echo 'mkcd path         -- create a directory (and all intervening directories) and cd into it'
    echo 'resolve           -- make the logical current directory match the physical one'
    echo 'psg pattern       -- grep with ps for the given pattern'
}
