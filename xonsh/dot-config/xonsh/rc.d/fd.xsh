def _fcd(args):
    from pathlib import Path
    first_matching_dir = $(fd --follow --hidden --glob --type d --max-results 1 @(args) err>/dev/null)
    if first_matching_dir:
        path = Path(first_matching_dir.strip())
        if path.is_dir():
            cd @(path)


def _fcd_of(args):
    from pathlib import Path
    first_match = $(fd --follow --hidden --glob --max-results 1 @(args) err>/dev/null)
    if first_match:
        parent_of_first_match = Path(first_match.strip()).parent
        cd @(parent_of_first_match)


def _fsource(args):
    paths = $(fd --follow --hidden --glob --type f @(args)).strip().split()
    source @(paths)


aliases |= {
    "f": lambda args: ![fd --follow --hidden --glob @(args) err>/dev/null],
    "fcat": lambda args: ![fd --follow --hidden --glob --type f @(args) --exec-batch bat],
    "fcd": _fcd,
    "fcd_of": _fcd_of,
    "fe": lambda args: ![fd --follow --hidden --glob --type f @(args) --exec-batch mvim -p],
    "fll": lambda args: ![fd --follow --hidden --glob @(args) --exec-batch exa -Fal],
    "fsource": _fsource,
    "ftree": lambda args: ![fd --follow --hidden --glob @(args) | as-tree]
}
