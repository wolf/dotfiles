# iTerm is only on macOS, why make this non-platform specific?
#   ...because iTerm can apply shell integration to remote hosts when using SSH

iterm2_print_user_vars() {
  printf "\033]0;%s\007" "${PWD##*/}"
}
