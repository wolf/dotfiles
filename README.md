## README

This is collection of my various configuration files, originally arranged for use with gnu `stow` but now I use my own
tool: `dotx`. `dotx` is written in Python and published on PyPI. You can install `dotx` using `uv` (I used to talk about
`pip` and `pipx` here, but I don't use those anymore). You'll need `uv` of course. If you don't already have it, start
here: [install uv](https://docs.astral.sh/uv/getting-started/installation/). Now back to `dotx`. Here is its
[page on PyPI](https://pypi.org/project/dotx/) in case you need the current version. Before you unpack the configuration
files with `dotx`, you do two things, (1) launch and exit `ipython` once so it creates its configuration directory
hierarchy; and (2) create a `~/.config` directory if you don't already have one. You install these dotfile
configurations by `cd`ing into your checked-out copy of `dotfiles` (a checked-out copy you will be keeping around) and
executing the command (well, at least the second command):

```bash
# Install dotx
uv tool install --prerelease=allow dotx

# Use dotx to install the dotfiles of interest
dotx --target=${HOME} \
    --ignore='README.*' --ignore='.mypy_cache' --ignore='.pytest_cache' --ignore='pycache' \
    install bash git readline tmux helix
```

...modulo the exact parts you want to install. This makes symbolic-links from your home directory to the top-level items
inside each of the listed directories. For example, inside the `dotfiles/bash` directory is a `dot-bashrc`,
`dot-bash_profile` and a directory: `dot-bash_topics.d`. Each of those gets a symbolic-link in your home directory
(except "dot-" is replaced with "."); and that lets bash start-up with our custom configuration. Because the links are
symbolic, you need to keep your `dotfiles` directory around forever. So make sure you put it someplace reasonable.

### non-standard tools

For Bash, I generally have installed several command-line tools that I find helpful. I have the complete collection on
macOS and all my Linux boxes. Some/most of these tools are not easily installed on Windows, so my Bash initialization
takes platform-specific definitions into account. See `bash/README.md` for details.

### local-only branch

This repo comprises the things that are the same between my various machines, but some things are different per machine
or secret and should not be uploaded. Therefore, when I clone the repo, I immediately make a branch named `local-only`
that contains things like my work email address in the global `~/.config/git/config`, or a GitHub token to make `brew`
work better, or platform specific paths that I haven't factored out yet, etc. With no remote, an accidental `git push`
just fails when `local-only` is checked out; so no secrets get published. As changes come down to `main`, you choose
which you want in `local-only` with `cherry-pick`. In my global `git` configuration, I've set `push.default` to
`upstream`. Specifically in this repository I set `push.default` to `nothing` so that an accidental push while on the
`local-only` branch won't accidentally publish it. I highly recommend this technique.

Another by the way: don't upload your `.ssh` directory or any of the private keys it contains.
