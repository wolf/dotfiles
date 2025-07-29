# Zsh-specific history configuration
export HISTFILE=~/.zsh_history
export SAVEHIST=10000

# Zsh history options (equivalent to Bash HISTCONTROL=ignoreboth:erasedups)
setopt HIST_IGNORE_DUPS         # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS     # Remove older duplicates (like erasedups)
setopt HIST_IGNORE_SPACE        # Don't record commands starting with space
setopt HIST_FIND_NO_DUPS        # Don't show duplicates when searching
setopt HIST_SAVE_NO_DUPS        # Don't save duplicates to file
setopt SHARE_HISTORY            # Share history between sessions
setopt APPEND_HISTORY           # Append rather than overwrite (like histappend)
setopt INC_APPEND_HISTORY       # Write immediately, not at shell exit

# Zsh shell options (equivalent to Bash shopt settings)
setopt AUTO_CD                  # cd by typing directory name (like autocd)
setopt CORRECT                  # Spell correction for commands (like cdspell)

# Pattern-based ignoring (closest equivalent to HISTIGNORE)
HISTORY_IGNORE="(ls|ll|pwd|bg|fg|history|h20|..|exit|did)"

# Load the functions I will use with the up and down arrows.  Yes, this is more work than Bash.
# autoload -U up-line-or-beginning-search
# autoload -U down-line-or-beginning-search

# Create the matching zle widgets.  That's what let's me use them with bindkey.
# zle -N up-line-or-beginning-search
# zle -N down-line-or-beginning-search

# Bind to arrow keys
# bindkey '^[[A' up-line-or-beginning-search    # Up arrow
# bindkey '^[[B' down-line-or-beginning-search  # Down arrow

# But lets keep tab-completion as well.
bindkey '^I' menu-complete

alias h20='history -20'  # h20 : show the last 20 entries from history
