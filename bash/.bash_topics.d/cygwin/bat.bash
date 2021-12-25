command -v bat >/dev/null || return

alias cat=bat

# shellcheck disable=SC2155
export BAT_CONFIG_PATH="$(cygpath --windows ~/.config/bat/config)"

function bat() {
    local index
    local args=("$@")
    for index in $(seq 0 ${#args[@]}) ; do
        case "${args[index]}" in
            -*) continue ;;
            *)  [ -e "${args[index]}"  ] && args[index]="$(cygpath --windows "${args[index]}")" ;;
        esac
    done
    command bat "${args[@]}"
}
