#!/usr/bin/env python3

from collections import defaultdict
from dataclasses import dataclass
import re
import sys

# Things I want
#   * Use only Python stuff from the standard library
#   * Group functions by file
#   * Alphabetize within groups
#   * Don't show functions that aren't actually in the environment
#   * Don't show an overridden function, only the final definition
#   * make the actual help text all line up
#   * note which functions are exported and can be used in other scripts and functions
#   * show help for a single command if asked


@dataclass
class BashFunction:
    name: str
    is_exported: bool
    help: str
    definition_file: str
    line_number: int


def read_definition_files_paths(definition_files_file: str) -> list[str]:
    with open(definition_files_file, "r") as f:
        return f.read().split("\x00")[:-1]


def read_exported_commands(exported_commands_file: str) -> set[str]:
    with open(exported_commands_file, "r") as f:
        return set(f.read().splitlines(keepends=False))


def read_proposed_commands(proposed_commands_file: str) -> dict[str, dict[str, str]]:
    HELP_LINE_RE = re.compile("(?P<path>[^:]+):(?P<command>\w+):(?P<help>.*)")

    proposed_commands_grouped_by_path: dict[str, dict[str, str]] = defaultdict(dict)
    with open(proposed_commands_file, "r") as f:
        for line in f:
            m = HELP_LINE_RE.match(line)
            if m:
                path = m.group("path")
                command = m.group("command")
                help = m.group("help")
                proposed_commands_grouped_by_path[path][command] = help
    return proposed_commands_grouped_by_path


def get_defined_commands(
    declares_file: str, exported_commands: set[str], help: dict[str, dict[str, str]]
):
    DECLARATION_WITH_PATH_RE = re.compile(
        "(?P<command>\w+) (?P<line_number>\d+) (?P<path>.*)"
    )

    defined_commands: dict[str, BashFunction] = {}
    defined_commands_grouped_by_path: dict[str, dict[str, BashFunction]] = defaultdict(
        dict
    )
    with open(declares_file, "r") as f:
        for line in f:
            m = DECLARATION_WITH_PATH_RE.match(line)
            if m:
                command = m.group("command")
                path = m.group("path")
                bash_function = BashFunction(
                    name=command,
                    is_exported=command in exported_commands,
                    help=help[path][command],
                    definition_file=path,
                    line_number=int(m.group("line_number")),
                )
                defined_commands_grouped_by_path[path][command] = bash_function
                defined_commands[command] = bash_function
    return defined_commands, defined_commands_grouped_by_path


if __name__ == "__main__":
    definition_files_file = sys.argv[1]
    proposed_commands_file = sys.argv[2]
    declares_file = sys.argv[3]
    exported_commands_file = sys.argv[4]
    single_command_to_lookup: str | None = None
    if len(sys.argv) > 5:
        single_command_to_lookup = sys.argv[5]

    list_of_definition_files = read_definition_files_paths(definition_files_file)
    exported_commands = read_exported_commands(exported_commands_file)
    proposed_commands = read_proposed_commands(proposed_commands_file)

    commands, commands_grouped_by_path = get_defined_commands(
        declares_file, exported_commands, proposed_commands
    )

    if single_command_to_lookup:
        if single_command_to_lookup in commands:
            bash_function = commands[single_command_to_lookup]
            print(f"{bash_function.definition_file}:{bash_function.line_number}")
            print(f"{bash_function.name}  {bash_function.help}", end="")
            if bash_function.is_exported:
                print(" [EXPORTED]", end="")
            print()
    elif commands:
        padding_needed = max([len(name) for name in commands.keys()])
        section_separator = ""
        for path in list_of_definition_files:
            if path in commands_grouped_by_path:
                print(f"{section_separator}{path}")
                section_separator = "\n"
                for bash_function in sorted(
                    commands_grouped_by_path[path].values(), key=lambda x: x.name
                ):
                    print(
                        f"{bash_function.name:<{padding_needed}}  {bash_function.help}"
                    )
