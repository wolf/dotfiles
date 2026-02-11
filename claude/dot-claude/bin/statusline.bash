#!/usr/bin/env bash
set -u

# Read statusline context from stdin (JSON with model info, etc.)
INPUT=$(cat)
MODEL=$(echo "$INPUT" | jq -r '.model.display_name // empty')

# Determine the display path
if git rev-parse --git-dir >/dev/null 2>&1; then
    # Inside a git repo: show path relative to repo root, including repo name
    REPO_ROOT=$(git rev-parse --show-toplevel)
    REPO_NAME=$(basename "$REPO_ROOT")
    REL_PATH=$(git rev-parse --show-prefix)
    # REL_PATH has trailing slash if not empty, remove it
    if [[ -n "$REL_PATH" ]]; then
        DIR="${REPO_NAME}/${REL_PATH%/}"
    else
        DIR="$REPO_NAME"
    fi
    BRANCH=$(git branch --show-current 2>/dev/null)
elif [[ "$PWD" == "$HOME"* ]]; then
    # Under home directory: show with ~ prefix
    DIR="~${PWD#$HOME}"
    BRANCH=""
else
    # Elsewhere: show absolute path
    DIR="$PWD"
    BRANCH=""
fi

# Build output
STATUS="$DIR"
if [[ -n "$BRANCH" ]]; then
    STATUS="$STATUS ($BRANCH)"
fi
if [[ -n "$MODEL" ]]; then
    STATUS="$STATUS using $MODEL"
fi
echo "$STATUS"
