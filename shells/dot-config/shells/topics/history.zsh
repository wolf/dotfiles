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

# Zsh-specific keybindings (equivalent to Bash bind commands)
bindkey '^I' menu-complete                    # Tab for menu completion

# Cross-platform arrow key bindings for history search
# Use terminfo for maximum compatibility across different terminal emulators
if [[ -n "${terminfo[kcuu1]}" && -n "${terminfo[kcud1]}" ]]; then
    # Use terminfo sequences (works best in WSL2/Windows Terminal)
    bindkey "${terminfo[kcuu1]}" history-search-backward   # Up arrow
    bindkey "${terminfo[kcud1]}" history-search-forward    # Down arrow
else
    # Fallback to standard sequences (macOS/iTerm, Git Bash)
    bindkey '^[[A' history-search-backward     # Up arrow for history search
    bindkey '^[[B' history-search-forward      # Down arrow for history search
fi
alias h20='history -20'  # h20 : show the last 20 entries from history
