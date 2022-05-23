def _resolve_git_relative_path(relative_path):
    from pathlib import Path
    import re

    git_path_re = re.compile(r"(.*)/\.git(?:/.*)?$")

    here = str(Path.cwd())
    if m := git_path_re.match(here):
        top = Path(m.group(1))
    else:
        top = Path($(git rev-parse --show-toplevel).strip())

    if relative_path:
        return top / relative_path
    
    return top


def _cdtop(args):
    relative_path = args[0] if args else None
    ![cd @(_resolve_git_relative_path(relative_path))]
 

def _pushdtop(args):
    relative_path = args[0] if args else None
    ![pushd @(_resolve_git_relative_path(relative_path))]


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
