function hosts() {  # hosts : list Hosts configured in `~/.ssh/config`
    if [ -f "${HOME}/.ssh/config" ] ; then
        grep -e '^Host' "${HOME}/.ssh/config"
    fi
}
