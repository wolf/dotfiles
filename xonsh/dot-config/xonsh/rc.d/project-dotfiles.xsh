$DOTFILES_DIR = p"~/brain/projects/dotfiles"


aliases |= {
    "cddf": lambda args: $[cd @(($DOTFILES_DIR / args[0]) if args else $DOTFILES_DIR)],
    "pushddf": lambda args: $[pushd @(($DOTFILES_DIR / args[0]) if args else $DOTFILES_DIR)]
}
