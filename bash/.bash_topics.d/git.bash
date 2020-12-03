export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=1
export GIT_PS1_DESCRIBE_STYLE="branch"

function cdtop() {
    # usage: cdtop [<relative path>]
    # change directory to the top-level of a git working-copy, or to a path relative to that
    GIT_DIR=$(git rev-parse --git-dir)
    if [ -n "$GIT_DIR" ]; then
        cd "$GIT_DIR/../$1"
    fi
}

function pushdtop() {
    # usage: pushdtop [<relative path>]
    # pushd combined with cdtop
    GIT_DIR=$(git rev-parse --git-dir)
    if [ -n "$GIT_DIR" ]; then
        pushd "$GIT_DIR/../$1"
    fi
}

function since_commit() {
    # usage: since_commit 12345
    # usage: since_commit HEAD~3
    # list all the files modified by all the commits since the given commit,
    #   including currently unstaged changes
    COMMIT=${1:-HEAD}
    git diff $COMMIT --name-only --relative
}

function in_commit() {
    # usage: in_commit 12345
    # usage: in_commit HEAD~3
    # list all the files modified as part of the given commit
    COMMIT=${1:-HEAD}
    git diff $COMMIT ${COMMIT}\^ --name-only --relative
}

function dirty() {
    # git ls-files --modified --unmerged | awk '{ print $4 }' | sort -u
    git ls-files --modified | sort -u
}

function edit_since()   { $EDITOR $(since_commit $1); }
function edit_commit()  { $EDITOR $(in_commit $1); }
function edit_dirty()   { $EDITOR $(dirty); }
