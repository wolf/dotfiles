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
alias tree='tree -lC -I .git'
alias grep='grep --color'

if command -v nvim >/dev/null; then
    export EDITOR='nvim'
else
    export EDITOR='vim'
fi

if [[ -d .bash_topics.d ]]; then
    for topic in .bash_topics.d/*; do
        if [[ ! ${topic} =~ .bash_topics.d/~.* ]] ; then
            source ${topic}
        fi
    done
fi

umask go-wx

if [ $(uname) = 'Darwin' ] ; then
    # if I'm on MacOS X...

    if [ -z "${SSH_CONNECTION}" ] ; then
        alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
    fi

    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        source $(brew --prefix)/etc/bash_completion
    fi
else
    if [ -f ~/.git-completion.bash ] ; then
        source ~/.git-completion.bash
    fi
    if [ -f ~/.git-prompt.sh ] ; then
        source ~/.git-prompt.sh
    fi

    export PATH=$PATH:/usr/local/sbin:~/bin
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_info()  { [ $VIRTUAL_ENV ] && echo ' ('$(basename $VIRTUAL_ENV)')'; }
function tip()              { git rev-parse --short HEAD 2>/dev/null; }
function time_since_last_commit { git log --no-walk --format="%ar" 2>/dev/null | sed 's/\([0-9]\) \(.\).*/\1\2/'; }

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
    export PS1='\n\! \u@\h:\[\e[35m\]\W\[\e[0m\]$(virtualenv_info) $(__git_ps1 "\[\e[32m\][$(time_since_last_commit) %s $(tip)]\[\e[0m\]")\$ '
else
    export PS1='\n\! \u@\h:\[\e[35m\]\W\[\e[0m\]$(virtualenv_info)\$ '
fi

export HISTSIZE=10000
export HISTIGNORE="&:ls:[bf]g:exit:history:..:pwd:ll:did"
shopt -s histappend cdspell autocd

function did() { history | grep "$1" | grep -v 'did'; }

bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

function f() {
    # usage: f <name>
    # find the filesystem object with the given name
    find . -name "$1" 2>/dev/null
}

function fx() {
    find . -name "$1" 2>/dev/null | xargs ls ${colorflag} -Falhd
}

function fcd() {
    # usage: fcd <directory_basename>
    # example: fcd js
    # find the directory with the given name, cd-ing into the first match found
    cd "$(find . -name "$1" -type d 2>/dev/null | awk "BEGIN { getline; print }")"
}

function en()   { $EDITOR "$(find . -name "$1" -type f 2>/dev/null)"; }
function ew()   { $EDITOR "$(which "$1")"; }
function lw()   { ll "$(which "$1")"; }
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
    echo 'psg pattern       -- grep with ps for the given pattern'
}
