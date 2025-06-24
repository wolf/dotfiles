# Import `LS_COLORS` into Zsh completion system
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
