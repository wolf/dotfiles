#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "typer",
#     "typing_extensions",
# ]
# ///
"""
$PATH may contain (useless) duplicates.  Running `eval "$(deduplicate_path.py)"` eliminates them.

To be run once as the very last thing that happens in the Bash (and this is a Bash-only script) startup sequence.
"""

import os
import platform
from pathlib import Path, PureWindowsPath
from typing import List, Optional

import typer
from typing_extensions import Annotated


original_paths = os.getenv("PATH")  # Technically this can return `None`.  I handle it, but it will never really happen.
output_paths = ""

_is_windows = platform.system() == "Windows"
_path_separator = ";" if _is_windows else ":"
_paths_already_present = set()


def is_new_path(path: str) -> bool:
    """`True` if we've seen `path` before; `False` otherwise"""
    global _paths_already_present
    if path in _paths_already_present:
        return False
    _paths_already_present.add(path)
    return True


def posix_path(path: str) -> Path:
    """
    Convert a platform-dependent string into a `pathlib.Path`

    Why is this hard?  Git Bash for Windows is a special case.  WSL acts exactly like any other Linux. It is not
    special.  I don't run any other Windows-specific Bash environments, so Git Bash for Windows is all I have to worry
    about.

    Here's the weird thing Git Bash for Windows does: within a Bash session, if you `echo $PATH`, you will what looks
    like a POSIX-style path.  It will have forward slashes, `/`.  Each path will be separated by a colon, `:`.  And
    no path in the list will start with drive letter, e.g., you won't see `E:`, you'll see `/e/...`.  This is fiction.
    If you get `PATH` from with Python (go ahead and test with IPython) you'll see what you see in Windows system
    environment variables dialog.  `PATH` is a list of directories separated by semicolons, `;`.  The slashes go the
    other way.  And any invidiual path that start from a specific volume begins with a drive letter, e.g., `E:`.

    Git Bash for Windows automatically translates between these two different representations of `PATH`.  On Windows,
    my `original_paths` looks like Windows paths.  Converting a Windows path from `str` form into a `PureWindowsPath`
    fixes the slashes, but if there's a drive letter, I have to handle that myself.

    Could I have converted all of `original_paths` at once?  Yes.  I think it would be more complicated and probably use
    regular expressions.  `$PATH` doesn't have a ton of elements.  Simple is fast enough.
    """
    if _is_windows:
        p = PureWindowsPath(path)
        if not p.drive:
            return Path(p)
        drive = p.drive[0].lower()
        everything_else = str(p)[len(drive) + 1 :]
        return Path(f"/{drive}/{everything_else}")
    else:
        return Path(path)


def main(
    remove: Annotated[Optional[List[Path]], typer.Option(help="A directory to remove from `$PATH`")] = None,
):
    paths_to_remove = set()
    if remove is not None:
        paths_to_remove = {posix_path(str(path)) for path in remove}

    if original_paths is not None:
        deduplicated_paths = [posix_path(path) for path in original_paths.split(_path_separator) if is_new_path(path)]

        # Because the result will always be handled inside Bash, I produce the well-known, `:` separated, forward slash
        # version of `$PATH`.
        output_paths = ":".join(
            path.as_posix() for path in deduplicated_paths[1:] if path not in paths_to_remove
        )  # Using the slice `[1:]` trims the path `uv` added just to run this script.
    else:
        # TODO: original_paths has the wrong format on Windows.  Yes, this can never happen; but fix it anyway.
        output_paths = original_paths

    print(f'export PATH="{output_paths}"')


if __name__ == "__main__":
    typer.run(main)
