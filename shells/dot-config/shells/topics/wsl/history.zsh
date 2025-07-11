# Cross-platform arrow key bindings for history search
# Use terminfo for maximum compatibility across different terminal emulators
if [[ -n "${terminfo[kcuu1]}" && -n "${terminfo[kcud1]}" ]]; then
    # Use terminfo sequences (works best in WSL2/Windows Terminal).  Remember: the platform-generic version
    # has already auto-loaded the needed functions and created the zle widgets.
    bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search      # Up arrow
    bindkey "${terminfo[kcud1]}" down-line-or-beginning-search    # Down arrow

    # If we don't have these definitions in terminfo, then we'll live with the bindings provided in the
    # platform-generic implementation.
fi
