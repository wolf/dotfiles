# Common history settings for both Bash and Zsh
export HISTSIZE=10000

# Common aliases and functions
did() { history | grep -vw 'did' | grep "$@"; }   # did <regexp> : list commands from history matching <regexp>
