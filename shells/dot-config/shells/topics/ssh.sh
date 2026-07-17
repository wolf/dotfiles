function hosts() {  # hosts : list Hosts configured in `~/.ssh/config`, following Include directives
    if command -v ssh-hosts >/dev/null 2>&1 ; then
        ssh-hosts "$@"
    else
        echo "hosts: ssh-hosts not installed; run: cargo install --path ~/develop/wolf/ssh-hosts" >&2
        return 127
    fi
}
