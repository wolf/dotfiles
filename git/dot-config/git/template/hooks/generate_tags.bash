#!/usr/bin/env bash
set -e
trap 'rm -f "$$.tags"' EXIT
git ls-files | \
    ctags --tag-relative -L - -f"$$.tags"
mv "$$.tags" tags
