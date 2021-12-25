### non-standard tools

I define a couple dozen or so Bash functions and aliases.  These definitions depend on some non-standard tools:

* [`bat`](https://github.com/sharkdp/bat): a replacement for `cat`
* [`exa`](https://github.com/ogham/exa): a replacement for `ls`
* [`fd`](https://github.com/sharkdp/fd): a replacement for `find`
* [`as-tree`](https://github.com/jez/as-tree): pipe a list of files into it to print them as a tree
* [ripgrep (`rg`)](https://github.com/BurntSushi/ripgrep): a replacement for `grep`
* [`fzf`](https://github.com/junegunn/fzf): a "fuzzy finder"

While my functions and aliases don't depend on them, I am a heavy user of:

* [`mcfly`](https://github.com/cantino/mcfly): a replacement for Ctrl-R
* [`tldr`, the tealdeer implementation](https://github.com/dbrgn/tealdeer): a supplement to `man`

These tools are easy to install on macOS or Linux using [homebrew](https://brew.sh/).  On Linux they might also be available through your system package manager.  Unfortunately, most of them are not easily installed on Windows (not counting WSL).  You can get `bat`, `fd`, and `rg`; but the others are tough.  So here's what I've done: in the `.bash_topics.d` directory, at the top-level, are a set of cross-platform files (ending in `.bash`) to be sourced, all of which mostly presume the needed tools are installed.  Also inside `.bash_topics.d` are sub-directories named for specific platforms.  In particuler, the `msys` sub-directory has files that re-define all those functions and alias using only Bash standard tools.
