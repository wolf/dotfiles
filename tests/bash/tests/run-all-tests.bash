#!/usr/bin/env bash

for SUITE in *.test ; do
    echo ; echo "Running ${SUITE}." ; echo
    "./${SUITE}"
done
