#!/usr/bin/env -S uv run --script
"""
$PATH may contain (useless) duplicates.  Running `eval "$(deduplicate_path.py)"` eliminates them.

To be run once as the very last thing that happens in the Bash startup sequence.
"""

import os
import platform
from pathlib import Path, PureWindowsPath

original_paths = os.getenv(
    "PATH"
)  # Technically this can return `None`.  I handle it, but it will never really happen.
output_paths = ""

_is_windows = platform.system() == "Windows"
_path_separator = ";" if _is_windows else ":"
_paths_already_present = set()


def is_new_path(path: str) -> bool:
    global _paths_already_present
    if path in _paths_already_present:
        return False
    _paths_already_present.add(path)
    return True


def posix_path(path: str) -> Path:
    if _is_windows:
        p = PureWindowsPath(path)
        if not p.drive:
            return Path(p)
        drive = p.drive[0].lower()
        everything_else = str(p)[len(drive) + 1:]
        return Path(f"/{drive}/{everything_else}")
    else:
        return Path(path)


if original_paths is not None:
    deduplicated_paths = [
        posix_path(path) for path in original_paths.split(_path_separator) if is_new_path(path)
    ]
    output_paths = ":".join(
        path.as_posix() for path in deduplicated_paths[1:]
    )  # Trim the path added by `uv` just to run this script.
else:
    output_paths = original_paths

print(f'export PATH="{output_paths}"')
