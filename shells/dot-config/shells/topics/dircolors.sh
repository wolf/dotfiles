if [ -f ~/.dir_colors ] ; then
    # shellcheck disable=SC2046
    eval $(dircolors --sh ~/.dir_colors)
fi
