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

from os import getenv
import platform
from pathlib import Path
from typing import List, Optional

import typer
from typing_extensions import Annotated

from posix_path import posix_path


original_paths = getenv("PATH")  # Technically this can return `None`.  I handle it, but it will never really happen.
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


def main(
    remove: Annotated[Optional[List[Path]], typer.Option(help="A directory to remove from `$PATH`")] = None,
):
    paths_to_remove = set()
    if remove is not None:
        paths_to_remove = {posix_path(path) for path in remove}

    if original_paths is not None:
        deduplicated_paths = [
            posix_path(Path(path)) for path in original_paths.split(_path_separator) if is_new_path(path)
        ]

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
