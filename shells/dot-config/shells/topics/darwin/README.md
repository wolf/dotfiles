# A Note About Paths

On macOS, to get exactly the paths I want on `$PATH`, I modify `/etc/paths`.  It may be that this file gets overwritten
on OS updates or re-installs, so this README file is here to remind me.  Currently, this is what I put in `/etc/paths`:

```
/opt/homebrew/opt/coreutils/libexec/gnubin
/opt/homebrew/opt/gnu-sed/libexec/gnubin
/opt/homebrew/opt/gnu-getopt/bin
/opt/homebrew/bin
/opt/homebrew/sbin
/opt/homebrew/opt/llvm/bin

/usr/local/bin
/System/Cryptexes/App/usr/bin
/usr/bin
/bin
/usr/sbin
/sbin
```
