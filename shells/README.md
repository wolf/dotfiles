### the basic idea

This particular installable (by `dotx`) machinery provides support for Bash
and Zsh.

### non-standard tools

I define a couple dozen or so shell functions and aliases. These definitions depend on some non-standard tools:

- [`fd`](https://github.com/sharkdp/fd): a replacement for `find`
- [ripgrep (`rg`)](https://github.com/BurntSushi/ripgrep): a replacement for `grep`
- [`bat`](https://github.com/sharkdp/bat): a replacement for `cat`
- [`fzf`](https://github.com/junegunn/fzf): a "fuzzy finder"
- [`eza`](https://github.com/eza-community/eza): a replacement for `ls`
- [`as-tree`](https://github.com/jez/as-tree): pipe a list of files into it to print them as a tree

While my functions and aliases don't depend on them, I do also use:

- [`tldr`, the tealdeer implementation](https://github.com/dbrgn/tealdeer): a supplement to `man`

These tools are easy to install on macOS or Linux using [homebrew](https://brew.sh/). On Linux they might **also** be
available through your system package manager. Unfortunately, most of them are not as easily installed on Windows (not
counting WSL). On Windows the environment I'm using and talking about is [Git Bash for Windows](https://git-scm.com).
You can get `fd`, `rg`, and `bat`; but the others are tougher. So here's what I've done: in the `.config/shells/topics` (we'll call this the "topic root")
directory are a set of "topics" to be sourced, all of which mostly
presume the needed tools are installed. Also inside the topic root are sub-directories named for specific platforms.
In particuler, the `mingw` sub-directory has files that re-define many of those functions and aliases using only the tools
probably available, again, specifically when you are running Git Bash for Windows. I have recently found that
[`scoop`](https://scoop.sh) works great on Windows. It still doesn't have all the tools listed above, but it's easy and
helpful.

Right next to the topic root, you will find `.config/shells/bin`.  The topic files are sourced by your particular shell's startup file(s).
The topics sourced are provided by `get_topics.py`.  In the topic root, there are `*.sh` files (always sourced), `*.bash` files and `*.zsh` files.
Bash and Zsh topics are sourced according to which shell you are using.  See the comments and docstrings in `get_topics.py` to understand
what will be sourced, in what order (and how to control it), and how to override general functions/aliases with shell- or platform-specific
ones.
