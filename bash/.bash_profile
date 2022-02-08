if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/opt/gnu-getopt/bin:${PATH}:/opt/homebrew/opt/coreutils/libexec/gnubin"
elif [ -f /home/linuxbrew/.linuxbrew/bin/brew ] ; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export PATH="${HOME}/.bash_tools.bin:${PATH}"

if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
