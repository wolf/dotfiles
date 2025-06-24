#!/usr/bin/env -S uv run --no-project --script --quiet
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "typer",
#     "typing_extensions",
# ]
# ///
"""
A callable script or importable function that yields an ordered list of topic files to be sourced at shell startup.

Requirements
------------
- What shell is this for, in the form of the filename extension acceptable topics will have (e.g., .bash, .zsh)
- What directory contains the topic files, in the form of a directory `Path`
- If all available topics are required, or else only topics needed for non-interactive shell startup

Assumptions and Methodology
---------------------------
- We only support Bash ("*.bash" topics) and Zsh ("*.zsh" topics) at the moment, though adding others should be
    as simple as adding another file extension in `main`.
- Topics that work under both shells are of the form "*.sh", and are always part of the answer if found.
- Platform-specific directories live as immediate children of the topics directory.  Just like the topics directory
    itself, they might contain any or all of the three different kinds of topics.
- We don't need to be told the platform, we can ask that with the `get_platform` function which returns a string.
    That string will match the name of a platform-specific directory.  The platform-specific directories are
    immediate children of the root topics directory.
- In the topics directory there are some special, non-topic, files:
    - Each of the files is a text file containing an ordered list of topic names (stems), e.g., "git", not "git.sh",
        one name per line.  For all three files, that file need not exist.  If it does exist, it is allowed to
        be empty.  Either of those cases just mean no topics take part in that category.
    - "initial-topics" will be listed before otherwise unordered topics.
    - "final-topics" will be listed after otherwise unordered topics.
    - "non-interactive-topics".  The normal case is an interactive shell session, and all (or maybe almost all)
        of the topics are to be sourced and so appear in the result.  In a non-interactive shell session, far
        fewer of them need to be sourced.  "non-interactive-topics" lists the narrower set of topics that are
        applicable for that case.  If this is to be a non-interactive session, the normal algorithm applies,
        except that no topic **not** in this list will be returned.  To repeat, the order of topic (stems) in
        "non-interactive-topics" is not important.  The order is still controlled by "initial-topics" and
        "final-topics".
- When a particular topic is to be included in the result, there may be zero or more actual topic files, e.g.,
    for the topic "git", there might be "git.sh", "git.bash", "darwin/git.sh"...
- The resulting list is ordered such that "*.sh" paths come first, then shell-specific topic paths.
- General topic paths come before platform-specific paths.  In this way, platform-specific topics can override
    things from the general version of the topic.
- All the paths for a given topic will be grouped together in the result.
- "initial-topics" and "final-topics" may match inside the platform-specific directories.  Such matches appear in the
    result as expected, and again, if there are also general topics of the same name, the platform-specific topics
    follow, so they might override
- In all functions here, I try to be very open to the types of input, and very specific in the types of the result.

Examples
--------
From command line:
    $ get_topics.py ~/.config/shell/topics zsh

From Python:
    >>> from get_topics import get_topics
    >>> paths = get_topics('~/.config/shell/topics', ['zsh'])
"""

import sys
from collections.abc import Container, Iterable, Sequence
from itertools import product
from os import PathLike
from pathlib import Path
from typing import TextIO

import typer
from typing_extensions import Annotated

from get_platform import get_platform
from posix_path import posix_path


def print_paths(
    paths: Iterable[PathLike | str],
    separator: str = "\n",
    file: TextIO = sys.stdout,
) -> None:
    """
    Print filesystem paths to a file with configurable separator.

    This is a very simple function, but it is factored out because it is useful when debugging.  In fact,
    that's why the `file` parameter exists.  While debugging you might want to send the paths to `stderr`
    or into a file in the file-system, etc.

    Parameters
    ----------
    paths : Iterable[PathLike | str]
        Collection of filesystem paths to print.
    separator : str, default "\n"
        String to use between paths.
    file : file-like object, default sys.stdout
        Where to write the output.
    """
    print(separator.join(str(posix_path(path)) for path in paths), file=file, end="")


def actual_dirs(dirs: Sequence[PathLike | str]) -> list[Path]:
    """
    Filter (the input) `dirs` down to a `list` of only `Path`s that actually exist and **are** directories.

    Lists of directories are always order sensitive in my use cases.  That's why `dirs` is a `Sequence`.
    """
    return [actual_dir for dir in dirs if (actual_dir := Path(dir)).is_dir()]


def read_topic_stems(input_path: PathLike | str) -> list[str]:
    """
    Return an ordered `list` of topic names (stems) from a text file, which provides them, one per line.

    The topic names are just stems, that is, they don't end with ".sh", ".bash", or ".zsh".  This function knows
    nothing about extensions or actual topic files matching these stems, or even where to look for them.  This
    input file need not exist.  It might exist but be empty.  `read_topic_stems` always returns a list, even in
    these cases; but of course, for these "empty" cases, the result is an empty list.

    This is a pretty easy task.  I could have done it in place each time; but I do it several times, so it made
    sense to factor it.
    """
    path = Path(input_path)
    if path.exists():
        with open(path, "r") as f:
            return f.read().splitlines()
    return []


def find_existing_topic_stems(topic_roots: Sequence[PathLike | str], extensions: Sequence[str]) -> set[str]:
    """
    Look for topics that actually exist in the filesystem and return a set of topic stems, e.g., "pixi" not "pixi.zsh".

    The result is unordered.
    """
    actual_topic_roots = set(actual_dirs(topic_roots))
    assert actual_topic_roots, "Error: you must provide at least one existing directory intended to contain topics."

    assert extensions, "Error: you must provide at least one filename extension."
    assert len(set(extensions)) == len(extensions), "Error: some extensions are listed more than once!"

    # Yes, it's a nested comprehension.  Other places in this file I use `itertools.product`.  In this case
    # the nested comprehension is clearer.
    return {
        topic.stem
        for extension in extensions
        for path in actual_topic_roots
        for topic in path.glob(f"*.{extension}")
    }


def resolve_topic_paths(
    topic_names: Iterable[str],
    topic_roots: Sequence[PathLike | str],
    extensions: Sequence[str],
) -> tuple[set[str], list[Path]]:
    """
    Produce both a set of topics (stems only) and a list of `Path`s from a collection of topic stems.

    `topic_roots` and `extensions` are expected to be ordered; and this function respects that order.
    `topic_names` might be anything.  A set is reasonable.  If you pass in an ordered collection, yes,
    that order will be respected.

    There can be zero or more resulting `Path`s for each topic name.  The resulting list is typically
    greater than the number of supplied names.

    This is the function that ensures actual paths to files are ordered, e.g., like so:

        git.sh                # General shell-agnostic topics
        git.bash              # Shell-specific topics
        darwin/               # Platform-specific overrides
        ├── git.sh
        └── git.bash

    All the files for a given topic are together.  If `topic_names` is ordered, then the corresponding
    paths appear (clumped) in that order.
    """
    topic_stems = set(topic_names)
    actual_topic_roots = actual_dirs(topic_roots)

    # The list of directories to search must not contain duplicates; because that could make us return
    # the same topic path more than once.
    assert len(set(actual_topic_roots)) == len(actual_topic_roots), (
        "Error: some directories appear more than once in the input to `resolve_topic_paths`."
    )

    ordered_topic_paths: list[Path] = [
        topic_path
        for topic_stem, extension, topic_root in product(topic_names, extensions, actual_topic_roots)
        if (topic_path := topic_root / f"{topic_stem}.{extension}").exists()
    ]

    # If the result isn't a list of unique values, that must be a programming error.
    assert len(set(ordered_topic_paths)) == len(ordered_topic_paths), (
        "Error: some `Path`s appear more than once in the result of `resolve_topic_paths`."
    )

    return topic_stems, ordered_topic_paths


def resolve_topic_paths_from_file(
    topics_list_file: PathLike | str,
    topic_roots: Sequence[PathLike | str],
    extensions: Sequence[str],
    limit_topics_to: Container[str] | None = None,
) -> tuple[set[str], list[Path]]:
    """
    Load topic names from a file and resolve them to filesystem paths.

    Reads topic stem names from a text file (one per line) and finds the
    corresponding topic files in the filesystem. Optionally filters the
    loaded topics to a subset.

    Parameters
    ----------
    topics_list_file : PathLike | str
        Path to text file containing topic names, one per line. File may
        not exist or may be empty.
    topic_roots : Sequence[PathLike | str]
        Directories to search for topic files, in priority order.
    extensions : Sequence[str]
        Filename extensions to search for (without leading dots).
    limit_topics_to : Container[str] or None, default None
        If provided, only include topics whose names are in this set.

    Returns
    -------
    tuple[set[str], list[Path]]
        A tuple containing:
        - Set of topic names (stems) that were processed
        - Ordered list of resolved topic file paths

    Notes
    -----
    This function delegates to `resolve_topic_paths` after loading and
    optionally filtering the topic names from the file.
    """
    filtered_topics = read_topic_stems(topics_list_file)
    if limit_topics_to is not None:
        # We can't just use set math because order matters: `filtered_topics` is a list.
        filtered_topics = [t for t in filtered_topics if t in limit_topics_to]
    return resolve_topic_paths(filtered_topics, topic_roots, extensions)


def ordered_unique_extensions(sequence: Sequence[str]) -> list[str]:
    # Here's our chance to weed out not just duplicates, but **anything** we can't use.
    seen: set[str] = set()
    result: list[str] = []

    # This would be **way** too complicated as a comprehension.
    for s in sequence:
        # If I turn the following condition into `not (...)`, it would contain a double-negative and be
        # harder to understand.
        if not s or not isinstance(s, str) or s == ".":
            continue
        if (s := s.lstrip(".")) not in seen:
            result.append(s)
            seen.add(s)
    return result


def get_topics(
    topics_root: PathLike | str,
    extensions: str | Sequence[str],
    non_interactive: bool = False,
) -> list[Path]:
    """
    Discover and order shell topic files for sourcing at startup.

    Finds all available topic files in a directory structure and returns them
    in the correct order for shell sourcing. Handles shell-agnostic (.sh) files,
    shell-specific files, platform-specific overrides, and special ordering
    requirements.

    Parameters
    ----------
    topics_root : PathLike | str
        Root directory containing topic files and configuration.
    extensions : str | Sequence[str]
        Shell-specific filename extensions to include (without leading dots),
        e.g., ['bash'] or ['zsh'].
    non_interactive : bool, default False
        If True, only return topics suitable for non-interactive shells
        as specified in the 'non-interactive-topics' file.

    Returns
    -------
    list[Path]
        Ordered list of topic file paths ready for shell sourcing.
        Empty list if no topics are found.

    Notes
    -----
    The function implements a sophisticated ordering algorithm:

    1. **File type priority**: .sh files come before shell-specific files
    2. **Directory priority**: General topics before platform-specific overrides
    3. **Special ordering**: Respects 'initial-topics' and 'final-topics' files
    4. **Platform detection**: Automatically includes platform-specific directory

    Expected directory structure::

        topics_root/
        ├── initial-topics          # Optional: topics to source first
        ├── final-topics           # Optional: topics to source last
        ├── non-interactive-topics # Optional: subset for non-interactive shells
        ├── git.sh                # General shell-agnostic topics
        ├── git.bash              # Shell-specific topics
        └── darwin/               # Platform-specific overrides
            ├── git.sh
            └── git.bash

    Constraints
    -----------
    The search for topics will always include the platform specific topics directory,
    if there is one for this platform.  The search for topics will always include files
    with the ".sh" extension.  If you really wanted, you could get **only** the ".sh"
    topics, but I don't know why you'd want that.

    Examples
    --------
    >>> topics = get_topics('~/.config/shell/topics', ['bash'])
    >>> len(topics)
    12
    >>> topics[0].name
    'initial.sh'
    """
    #
    # Validate and/or fix all parameters
    #

    # You have to give me a good directory to start in.  I can't fix it if you don't.
    general_topics_root = Path(topics_root)
    assert general_topics_root.is_dir(), "Error: a valid directory must be supplied (where to search for topics)."

    # There's a couple of things you **might** do wrong in communicating the extensions you want.  Some things I can
    # fix (so I do), and some things I can't (so I assert).

    # Can fix: if the caller provided a non-empty string instead of a list of strings, convert it into a list of strings.
    if extensions and isinstance(extensions, str) and extensions != ".":
        extensions = [extensions]
    # So now, `extensions` must be a (plausible) list, or else a bad string.  A bad string, or even a bad list will
    # be caught by the following `assert`.

    # Can't fix: caller must supply at least one non-empty string ("." doesn't coun't because that will **become** an
    # empty string when I strip leading dots).
    assert extensions and isinstance(extensions, list) and any(e and isinstance(e, str) and e != "." for e in extensions), \
        "Error: at least one non-empty filename extension (a string, not starting with '.') must be given."

    # Can fix: weed out anything that's not a non-empty string; drop any "." prefixes; make sure "sh" is included, and
    # appears first in the list.  We already know that extensions contains at least one real string.
    extensions = ordered_unique_extensions(["sh"] + list(extensions))

    #
    # Make a list of all the directories we will search; and build a `set` of all the topic (stems) we find there.
    #

    all_topic_roots = [general_topics_root]
    if (platform_topics_root := general_topics_root / get_platform()).exists():
        all_topic_roots += [platform_topics_root]

    # Important: `all_topics` will also include topic names found **only** in platform-specific directories.
    all_topics = find_existing_topic_stems(all_topic_roots, extensions)

    if not all_topics:
        # If no actual topics exist, that's not an error.  It just means there's nothing to return.
        return []

    #
    # If this is to be a non-interactive shell session, we may not need all the available topics.
    #

    non_interactive_topics_file = general_topics_root / "non-interactive-topics"
    if non_interactive_topics_file.exists() and non_interactive:
        limit_topics_to = set(read_topic_stems(non_interactive_topics_file))
        all_topics &= limit_topics_to
    else:
        limit_topics_to = None

    #
    # Now collect, separately both the initial topics and final topics
    #
    # For both initial and final, grab a set of topic (stems) in addition to the ordered topic file.  We use those
    # to do set math to calculate which topics to include in "everything that's left"
    #

    initial_topics, ordered_initial_topic_paths = resolve_topic_paths_from_file(
        general_topics_root / "initial-topics",  # It's okay for this file to not exist, or to exist and be empty.
        all_topic_roots,
        extensions,
        limit_topics_to,
    )

    final_topics, ordered_final_topic_paths = resolve_topic_paths_from_file(
        general_topics_root / "final-topics",  # It's okay for this file to not exist, or to exist and be empty.
        all_topic_roots,
        extensions,
        limit_topics_to,
    )

    #
    # Collect everything that's left.  We know what's left by starting with the set of all available topics, and
    # subtracting everything that's already spoken for by initial and final.
    #

    # `all_topics` is already limited by `limit_topics_to`, so no need for further constraints.
    # Technically don't need `sorted` here.  I didn't promise to order topics not mentioned in initial or final;
    # but why not alphabetize them.  Of course they still obey the rules with a given topic: ".sh" before shell-
    # specific, general before platform-specific.
    _, ordered_other_topic_paths = resolve_topic_paths(
        sorted(all_topics - (initial_topics | final_topics)),
        all_topic_roots,
        extensions,
    )

    #
    # Now we have three non-overlapping lists of actual topic files in exactly the order we want!
    #

    return ordered_initial_topic_paths + ordered_other_topic_paths + ordered_final_topic_paths


def main(
    topics_dir: Annotated[Path, typer.Argument(help="The top-level topics directory")],
    shell: Annotated[str, typer.Argument(help="Return topics appropriate for this shell, e.g., 'zsh'")],
    print0: Annotated[bool, typer.Option(help="Separate paths with NULLs instead of line-breaks")] = False,
    non_interactive: Annotated[
        bool, typer.Option(help="Only return topics needed for a non-interactive shell session.")
    ] = False,
):
    if not topics_dir.is_dir():
        typer.echo(f"Error: Directory {topics_dir} does not exist", err=True)
        raise typer.Exit(1)

    if shell not in {"bash", "zsh", "sh"}:
        typer.echo(f"Warning: Unusual shell '{shell}' - supported: bash, zsh", err=True)

    topics_paths = get_topics(topics_dir, [shell], non_interactive)
    print_paths(topics_paths, separator="\0" if print0 else "\n")


if __name__ == "__main__":
    typer.run(main)
