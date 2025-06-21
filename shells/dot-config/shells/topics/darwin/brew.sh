if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/opt/gnu-getopt/bin:${PATH}:/opt/homebrew/opt/coreutils/libexec/gnubin"
fi
