## README

This is collection of my various configuration files, originally arranged for use with gnu `stow` but now I use my own tool: `dotx`.  `dotx` is written in Python and published on PyPI.  You can install `dotx` using `pip` or `pipx`.  Here is its [page on PyPI](https://pypi.org/project/dotx/) in case you need the current version.  Before you unpack the configuration files with `dotx`, you do two things, (1) launch and exit `ipython` once so it creates its configuration directory hierarchy; and (2) create a `~/.config` directory.  You install these configurations by `cd`ing into your checked-out copy of `dotfiles` (a checked-out copy you will be keeping around) and executing the command:

```
dotx --target=${HOME} \
    --ignore='README.*' --ignore='.mypy_cache' --ignore='.pytest_cache' --ignore='pycache' \
    install bash git readline tmux vim
```

...modulo the exact parts you want to install.  This makes symbolic-links from your home directory to the top-level items inside each of the listed directories.  For example, inside the `dotfiles/bash` directory is a `.bashrc`, `.bash_profile` and a directory: `.bash_topics.d`.  Each of those gets a same-named symbolic-link in your home directory; and that lets bash start-up with our custom configuration.  Because the links are symbolic, you need to keep your `dotfiles` directory around forever.  So make sure you put it someplace reasonable.

### Vim

`vim` is special, you need to do a little extra work to get its plugins downloaded.

```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

Then launch `vim` and type `:PluginInstall`.  There's a good progress indicator but expect the install to take a couple of minutes.

`emergency_vim/vimrc` is a file you can source while loading `vim` on a machine where you don't have all your special configuration files.  E.g., `vim -u vimrc some-file.js`.

### UltiSnips snippets

After you've run `vim`, the `~/.vim` directory should exist.  Now it's time to install your snippets, if you plan to use them.  If `~/.vim/UltiSnips` exists and is empty, delete it.  Then (or otherwise), run `dotx` again:

```
dotx --target=${HOME} install ultisnips
```

### non-standard tools

For Bash, I generally have installed several command-line tools that I find helpful.  I have the complete collection on macOS and all my Linux boxes.  Some/most of these tools are not easily installed on Windows, so my Bash initialization takes platform-specific definitions into account.  See bash/README.md for details.

### local-only branch

This repo comprises the things that are the same between my various machines, but some things are different per machine or secret and should not be uploaded.  Therefore, when I clone the repo, I immediately make a branch named `local-only` that contains things like my work email address in the global `.gitconfig`, or a GitHub token to make `brew` work better, or platform specific paths that I haven't factored out yet, etc.  With no remote, an accidental `git push` just fails when `local-only` is checked out; so no secrets get published.  As changes come down to `main`, you choose which you want in `local-only` with `cherry-pick`.  I highly recommend this technique.

By the way: don't upload your `.ssh` directory or any of the private keys it contains.
