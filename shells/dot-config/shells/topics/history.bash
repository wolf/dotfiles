# Bash-specific history configuration
export HISTCONTROL=ignoreboth:erasedups
export HISTFILE=~/.bash_history
export HISTIGNORE="&:ls:[bf]g:exit:history:h20:..:pwd:ll:did"
# export HISTTIMEFORMAT='%a, %m %b %Y, %H:%M:%S '

# Bash shell options
shopt -s histappend cdspell autocd histreedit

# Bash prompt command for history management
export PROMPT_COMMAND="update_readline_edit_mode_environment_variable; history -a; history -c; history -r; $PROMPT_COMMAND"
trap 'history -a' EXIT

# Bash-specific keybindings
bind '"\t":menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

alias h20='history 20'  # h20 : show the last 20 entries from history
