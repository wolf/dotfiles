def _resolve_git_relative_path(args):
    from pathlib import Path
    import re

    inside_git_dir = re.compile(r"(.*)/\.git(?:/.*)?$")

    rel_path = args[0] if args else None
    here = str(Path.cwd())
    if m := inside_git_dir.match(here):
        top = Path(m.group(1))
    else:
        top = Path($(git rev-parse --show-toplevel).strip())

    return top / rel_path if rel_path else top


def _cdtop(args):
    ![cd @(_resolve_git_relative_path(args))]


def _pushdtop(args):
    ![pushd @(_resolve_git_relative_path(args))]


def _dirty(args):
    return $(git ls-files --modified --deduplicate @(args)).strip().split()


def _edit_dirty(args):
    ![git ls-files --modified --deduplicate -z @(args) | xargs -o -0 mvim -p]


aliases |= {
    "cdtop": _cdtop,
    "pushdtop": _pushdtop,
    "dirty": _dirty,
    "edit_dirty": _edit_dirty
}
