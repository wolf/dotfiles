## README

This is collection of my various configuration files, arranged for use with gnu `stow`.  Before you unpack the configuration files with `stow`, you do two things, (1) launch and exit `ipython` once so it creates its configuration directory hierarchy; and (2) create a `~/.config` directory.  You install these configurations by `cd`ing into your checked-out copy of `dotfiles` (a checked-out copy you will be keeping around) and executing the command:

```
stow --target=${HOME} -S bash git readline tmux vim
```

...modulo the exact parts you want to install.  This makes symbolic-links from your home directory to the top-level items inside each of the listed directories.  For example, inside the `dotfiles/bash` directory is a `.bashrc`, `.bash_profile` and a directory: `.bash_topics.d`.  Each of those gets a same-named symbolic-link in your home directory; and that lets bash start-up with our custom configuration.  Because the links are symbolic, you need to keep your `dotfiles` directory around forever.  So make sure you put it someplace reasonable.

### Vim

`vim` is special, you need to do a little extra work to get its plugins downloaded.

```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

Then launch `vim` ignoring the error (if I haven't gotten around to fixing it yet), and type `:PluginInstall`.  There's a good progress indicator but expect the install to take several minutes.

`emergency_vim/vimrc` is a file you can source while loading `vim` on a machine where you don't have all your special configuration files.  E.g., `vim -u vimrc some-file.js`.

### NeoVim

NeoVim (`nvim`) is installed similarly to `vim`.  The exact command to get Vundle is

```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.config/nvim/bundle/Vundle.vim
```

### local-only branch

This repo comprises the things that are the same between my various machines, but some things are different per machine or secret and should not be uploaded.  Therefore, when I clone the repo, I immediately make a branch named `local-only` that contains things like my work email address in the global `.gitconfig`, or a GitHub token to make `brew` work better, or platform specific paths that I haven't factored out yet, etc.  With no remote, an accidental `git push` just fails when `local-only` is checked out; so no secrets get published.  As changes come down to `master`, you choose which you want in `local-only` with `cherry-pick`.  I highly recommend this technique.

By the way: don't upload your `.ssh` directory or any of the private keys it contains.
