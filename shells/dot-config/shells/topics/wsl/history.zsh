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
