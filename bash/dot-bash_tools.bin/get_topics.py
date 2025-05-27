#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "typer",
#     "typing_extensions",
# ]
# ///
import sys
from pathlib import Path

import typer
from typing_extensions import Annotated

from get_platform import get_platform


def print_paths(paths: set[Path] | list[Path], separator: str = "\n", file = sys.stdout) -> None:
    # This is factored out because it is useful when debugging
    print(separator.join(str(path) for path in paths), file=file)


def main(print0: Annotated[bool, typer.Option(help="Separate paths with NULLs instead of line-breaks.")] = False):
    home_dir = Path.home()
    topics_dir: Path = home_dir / ".bash_topics.d"
    platform_specific_topics_dir: Path = topics_dir / get_platform()

    initial_topics_file: Path = topics_dir / "initial_topics"
    final_topics_file: Path = topics_dir / "final_topics"

    # From here, I make several collections.  They are sets and have the prefix "all_".  When order is needed, there is
    # a matching list without the "all_".  Every one of them is a collection of `Path`s, that path is a leaf-name, and
    # that `Path` ends with ".bash", e.g., Path("starship.bash").  So every place I iterate, it is over a collection of
    # `Path`s.

    # Because I have designed this with only one possible "initial_topics" file, and one possible "final_topics" file,
    # and because there can be platform-specific topics that do _not_ shadow a general topic (that is, a topic that
    # exists _only_ in the platform-specific directory), and because you might want that platform-specific topic to be
    # sourced before or after everything else, the lists in "initial_topics" and in "final_topics" are tested against
    # both general and platform-specific topics independently.  If you have "mingw/jetbrains.bash" topic that exists
    # _only_ for "mingw", but you want it to be sourced last: just put it last in the "final_topics" file in the general
    # topics directory.  The right thing will happen.

    # You can supply a file that list topics that must be sourced first, one per line, in the order you want it to happen.
    # The file need not exist, or, if it does, it can be empty.  At the end of this block, we've collected those topics
    # into a list (because order is important here) and a set.
    initial_topics = []
    all_initial_topics = set()
    if initial_topics_file.exists():
        with open(initial_topics_file, "r") as f:
            # You are not required to add ".bash" onto the end, but I handle it if you do.
            initial_topics = [Path(topic if topic.endswith(".bash") else topic + ".bash") for topic in f.read().splitlines()]
            all_initial_topics = set(initial_topics)

    # You can supply a file that lists topics that must be sourced last, again, one per line in the order you want it to happen.
    # The file need not exist, or, if it does, it can be empty.  At the end of this block, we've collected those topics
    # into a list (because order is important here) and a set.
    final_topics = []
    all_final_topics = set()
    if final_topics_file.exists():
        with open(final_topics_file, "r") as f:
            # Again, you are not required to add ".bash" onto the end, but I handle it if you do.
            final_topics = [Path(topic if topic.endswith(".bash") else topic + ".bash") for topic in f.read().splitlines()]
            all_final_topics = set(final_topics)

    # Now we look in the topics directory for actual topic files.  Order is not important here, so we only make a set.
    all_topics = set(Path(topic.name) for topic in topics_dir.glob("*.bash"))
    # ...and we do the same for platform-specific topics.  Usually a platform-specific topic shadows a general topic and
    # overrides it.  Occasionally, a topic will _only_ exist in the platform-specific directory.
    all_platform_specific_topics = set(Path(topic.name) for topic in platform_specific_topics_dir.glob("*.bash"))

    result = []  # This is the complete ordered list of absolute `Path`s to topics that we will output at the end.

    for topic in initial_topics:  # Iterate over the list, because we need to source them in order.
        if topic in all_topics:
            # `all_topics` was created with `glob`, so we know for sure that `topic` exists.
            result.append(topics_dir / topic)
        if topic in all_platform_specific_topics:
            # `all_platform_specific_topics` was created with `glob`, so we know for sure that `topic` exists.
            result.append(platform_specific_topics_dir / topic)

    unordered_topics = all_topics - (all_initial_topics | all_final_topics)  # All the topics that aren't "spoken for"
    for topic in sorted(unordered_topics):
        result.append(topics_dir / topic)
        # If there's a platform-specific topic with the same name, we'll source that immediately after the general version.
        platform_specific_topic = platform_specific_topics_dir / topic
        if platform_specific_topic.exists():
            result.append(platform_specific_topic)

    # Any platform-specific topics that _don't_ shadow a general topic, i.e., that name exists _only_ in the platform-
    # specific directory, they must be sourced and they won't have been hit by the loop over `unordered_topics`, and we
    # have to source them _before_ we do the `final_topics`.  That means now.
    all_platform_specific_only_topics = all_platform_specific_topics - (all_topics | all_initial_topics | all_final_topics)
    for topic in sorted(all_platform_specific_only_topics):
        result.append(platform_specific_topics_dir / topic)

    for topic in final_topics:  # Iterate over the list, because we need to source them in order
        if topic in all_topics:
            # `all_topics` was created with `glob`, so we know for sure that `topic` exists.
            result.append(topics_dir / topic)
        if topic in all_platform_specific_topics:
            # `all_platform_specific_topics` was created with `glob`, so we know for sure that `topic` exists.
            result.append(platform_specific_topics_dir / topic)

    print_paths(result, separator = "\0" if print0 else "\n")


if __name__ == "__main__":
    typer.run(main)
