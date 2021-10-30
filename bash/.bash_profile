if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
