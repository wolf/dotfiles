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


# Why does _pushdtop have to be a separate function?
# Because when it's a lambda, it prints the stack twice.
def _pushdtop(args):
    ![pushd @(_resolve_git_relative_path(args))]


aliases |= {
    "cdtop": lambda args: ![cd @(_resolve_git_relative_path(args))],
    "pushdtop": _pushdtop,
    "dirty": lambda args: $(git ls-files --modified --deduplicate @(args)).strip().split(),
    "edit_dirty": lambda args: ![git ls-files --modified --deduplicate -z @(args) | xargs -o -0 mvim -p]
}
