#!/usr/bin/env bash
set -u

DIR="${PWD/#$HOME/~}"
BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
fi

if [[ -n "$BRANCH" ]]; then
    echo "$DIR ($BRANCH)"
else
    echo "$DIR"
fi
