# Initialize Zsh completion system FIRST
autoload -Uz compinit
compinit

# Complete aliases (e.g., `ll`) as the original command (e.g., for `ll`, as though calling `eza`)
setopt completealiases

# Add Homebrew's Zsh completion directory to fpath
if command -v brew >/dev/null 2>&1; then
    fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

# Optional: Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit
