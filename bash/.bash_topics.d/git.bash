
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_DESCRIBE_STYLE="branch"

function cdtop() {
    # usage: cdtop [<relative path>]
    # change directory to the top-level of a git working-copy, or to a path relative to that
    git_dir=$(git rev-parse --git-dir)
    if [ -n "$git_dir" ]; then
        cd "$git_dir/../$1"
    fi
}

function pushdtop() {
    # usage: pushdtop [<relative path>]
    # pushd combined with cdtop
    git_dir=$(git rev-parse --git-dir)
    if [ -n "$git_dir" ]; then
        pushd "$git_dir/../$1"
    fi
}

function since_commit() {
    # usage: since_commit 12345
    # usage: since_commit HEAD~3
    # list all the files modified by all the commits since the given commit,
    #   including currently unstaged changes
    commit=${1:-HEAD}
    git diff $commit --name-only --relative
}

function in_commit() {
    # usage: in_commit 12345
    # usage: in_commit HEAD~3
    # list all the files modified as part of the given commit
    commit=${1:-HEAD}
    git diff $commit ${commit}\^ --name-only --relative
}

function dirty() {
    # git ls-files --modified --unmerged | awk '{ print $4 }' | sort -u
    git ls-files --modified | sort -u
}

function edit_since()   { $EDITOR $(since_commit $1); }
function edit_commit()  { $EDITOR $(in_commit $1); }
function edit_dirty()   { $EDITOR $(dirty); }
