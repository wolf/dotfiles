# Initialize Zsh completion system FIRST
autoload -Uz compinit
compinit

# Add Homebrew's Zsh completion directory to fpath
if command -v brew >/dev/null 2>&1; then
    fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

# Optional: Load bash completion compatibility
autoload -U +X bashcompinit && bashcompinit
