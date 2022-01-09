# shellcheck disable=SC2046

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_DESCRIBE_STYLE="branch"

function tip() { # tip [<branch-name>] : print the (short) commit-id for <branch-name>, or HEAD if none given
    local BRANCH="${1:-HEAD}"
    git rev-parse --short "${BRANCH}" 2>/dev/null;
}

function time_since_last_commit {
    git log --no-walk --format="%ar" 2>/dev/null | sed 's/\([0-9]\) \(.\).*/\1\2/';
}

function cdtop() { # cdtop [<relative-path>] : cd to the top-level of the current git working-copy, or to a path relative to that
    local TOP_LEVEL

    if [[ "$(pwd)" =~ ^(.*)/.git([^[:alnum:]_]|$) ]] ; then
        TOP_LEVEL="${BASH_REMATCH[1]}"
    else
        TOP_LEVEL="$(git rev-parse --show-toplevel)"
    fi
    if [ -n "${TOP_LEVEL}" ] ; then
        cd "${TOP_LEVEL}/${1}" || return
    fi
}

function pushdtop() { # usage: pushdtop [<relative-path>] : pushd combined with cdtop
    local TOP_LEVEL

    if [[ "$(pwd)" =~ ^(.*)/.git([^[:alnum:]_]|$) ]] ; then
        TOP_LEVEL="${BASH_REMATCH[1]}"
    else
        TOP_LEVEL="$(git rev-parse --show-toplevel)"
    fi
    if [ -n "${TOP_LEVEL}" ] ; then
        pushd "${TOP_LEVEL}/${1}" || return
    fi
}

function dirty() { # dirty : list currently modified and/or unmerged files that exist in this repo
    git ls-files --modified --deduplicate "$@"
}

function edit_dirty() { # edit_dirty : like dirty, but open in $EDITOR instead of list
    # shellcheck disable=SC2086
    dirty "$@" -z | xargs -o -0 ${EDITOR}
}

if [ "$(command -v fzf)" ] ; then
    function zadd() { # zadd [<regexp>] : multi-select fzf over modified files filtered by <regexp>.  Choose the ones you want, and they are staged
        declare -a RG_ARGUMENTS
        if (( ! $# )) ; then
            RG_ARGUMENTS=(".")
        else
            RG_ARGUMENTS=("$@")
        fi
        git ls-files --modified --others --exclude-standard --deduplicate \
            | rg "${RG_ARGUMENTS[@]}" \
            | fzf --print0 --multi --preview-window='60%' --preview='bat --color=always --style=header,changes,grid {}' \
            | xargs -0 git add
    }

    function zshow() { # zshow [git-log-options...] : brings up fzf over a log of selected commits, then shows the chosen one
        # example: zshow
        # example: zshow --author=Wolf --since="{2 days ago}"
        local COMMITS_TO_SHOW

        # shellcheck disable=SC2016
        COMMITS_TO_SHOW="$( \
            git log --abbrev-commit --oneline "$@" \
            | fzf --multi --preview-window='60%' --preview='git show --color=always $(echo {} | cut -d " " -f 1)' \
            | cut -d ' ' -f 1 \
        )"
        if [ -n "${COMMITS_TO_SHOW}" ] ; then
            # shellcheck disable=SC2086
            git show ${COMMITS_TO_SHOW}
        fi
    }
fi
