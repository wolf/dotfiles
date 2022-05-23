$RIPGREP_CONFIG_PATH = p"~/.config/rg/config"


def _gv(args):
    from tempfile import mkstemp
    _, tempfile_path = mkstemp(dir='/tmp')
    rg --follow --hidden --smart-case --vimgrep @(args) > @(tempfile_path)
    mvim -q @(tempfile_path) -c ":copen | :bdelete 1"


aliases |= {
    "g": lambda args: $[rg --follow --hidden --smart-case --heading @(args)],
    "grep": lambda args: $[rg --follow --hidden --smart-case --heading @(args)],
    "ge": lambda args: $[rg --follow --hidden --smart-case --files-with-matches -0 @(args) | xargs -0 -o mvim -p],
    "gv": _gv
}
