# shellcheck disable=SC2046

export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_DESCRIBE_STYLE="branch"

function tip() { # tip [<branch-name>] : print the (short) commit-id for <branch-name>, or HEAD if none given
    BRANCH="${1:-HEAD}"
    git rev-parse --short "${BRANCH}" 2>/dev/null;
}

function time_since_last_commit {
    git log --no-walk --format="%ar" 2>/dev/null | sed 's/\([0-9]\) \(.\).*/\1\2/';
}

function cdtop() { # cdtop [<relative-path>] : cd to the top-level of the current git working-copy, or to a path relative to that
    TOP_LEVEL="$(git rev-parse --show-toplevel)"
    if [ -n "${TOP_LEVEL}" ] ; then
        cd "${TOP_LEVEL}/${1}" || return
    fi
}

function pushdtop() { # usage: pushdtop [<relative-path>] : pushd combined with cdtop
    TOP_LEVEL="$(git rev-parse --show-toplevel)"
    if [ -n "${TOP_LEVEL}" ] ; then
        pushd "${TOP_LEVEL}/${1}" || return
    fi
}

function since_commit() { # since_commit [<ref>] : list all the files modified by all the commits since the given <ref>, including currently unstaged changes
    # example: since_commit
    # example: since_commit 12345
    # example: since_commit HEAD~3
    COMMIT="${1:-HEAD}"
    git diff "${COMMIT}" --name-only --relative
}

function in_commit() { # in_commit [<ref>] : list all the files modified as part of the given commit
    # example: in_commit
    # example: in_commit 12345
    # example: in_commit HEAD~3
    COMMIT="${1:-HEAD}"
    git diff "${COMMIT}" "${COMMIT}^" --name-only --relative
}

function dirty() { # dirty : list currently modified and/or unmerged files that exist in this repo
    git ls-files --modified | sort -u
}

function edit_since()   { ${EDITOR} $(since_commit "${1}"); }       # edit_since [<ref>] : like since_commit, but open in $EDITOR instead of list
function edit_commit()  { ${EDITOR} $(in_commit "${1}"); }          # edit_commit [<ref>] : like in_commit, but open in $EDITOR instead of list
function edit_dirty()   { ${EDITOR} $(dirty); }                     # edit_dirty : like dirty, but open in $EDITOR instead of list

if [ "$(command -v fzf)" ] ; then
    function fzf_git_show() { # fzf_git_show [git-log-options...] : brings up fzf over a log of selected commits, then shows the chosen one
        # example: fzf_git_show
        # example: fzf_git_show --author=Wolf --since="{2 days ago}"
        COMMIT_TO_SHOW="$(git log --abbrev-commit --oneline "$@" | fzf | cut -d ' ' -f 1)"
        if [ -n "${COMMIT_TO_SHOW}" ] ; then
            git show "${COMMIT_TO_SHOW}"
        fi
    }
fi
