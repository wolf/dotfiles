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

    TOP_LEVEL="$(git rev-parse --show-toplevel)"
    if [ -n "${TOP_LEVEL}" ] ; then
        cd "${TOP_LEVEL}/${1}" || return
    fi
}

function pushdtop() { # usage: pushdtop [<relative-path>] : pushd combined with cdtop
    local TOP_LEVEL

    TOP_LEVEL="$(git rev-parse --show-toplevel)"
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
    function zadd() { # zadd : brings up multi-select fzf over the set of files you can add.  Choose whichever ones you want, and they are added
        git ls-files --modified --others --exclude-standard --deduplicate -z \
            | fzf --read0 --print0 --multi --preview-window='60%' --preview='bat --color=always --style=header,changes,grid {}' \
            | xargs -0 git add
    }

    function zshow() { # zshow [git-log-options...] : brings up fzf over a log of selected commits, then shows the chosen one
        # example: zshow
        # example: zshow --author=Wolf --since="{2 days ago}"
        local COMMIT_TO_SHOW

        COMMIT_TO_SHOW="$(git log --abbrev-commit --oneline "$@" | fzf | cut -d ' ' -f 1)"
        if [ -n "${COMMIT_TO_SHOW}" ] ; then
            git show "${COMMIT_TO_SHOW}"
        fi
    }
fi
