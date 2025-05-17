#!/usr/bin/env -S uv run --script
"""
$PATH may contain (useless) duplicates.  Running `eval "$(deduplicate_path.py)"` eliminates them.

To be run once as the very last thing that happens in the Bash startup sequence.
"""

import os

original_paths = os.getenv(
    "PATH"
)  # Technically this can return `None`.  I handle it, but it will never really happen.
output_paths = ""

_paths_already_present = set()


def is_new_path(path: str) -> bool:
    global _paths_already_present
    if path in _paths_already_present:
        return False
    _paths_already_present.add(path)
    return True


if original_paths is not None:
    # Split on `:`s gives us a list.  No element is quoted.  `is_new_path` tells us which to keep.
    # No quoting for individual elements is needed because the entire concatenated value will be quoted at the end.
    deduplicated_paths = [
        path for path in original_paths.split(":") if is_new_path(path)
    ]
    output_paths = ":".join(
        deduplicated_paths[1:]
    )  # Trim the path added by `uv` just to run this script.
else:
    output_paths = original_paths

print(f'export PATH="{output_paths}"')
