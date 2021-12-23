# used to reattach ssh forwarding to "stale" tmux sessions
# http://justinchouinard.com/blog/2010/04/10/fix-stale-ssh-environment-variables-in-gnu-screen-and-tmux/
function refresh_ssh() {
    if [[ -n ${TMUX} ]]; then
        NEW_SSH_AUTH_SOCK="$(tmux showenv | grep ^SSH_AUTH_SOCK | cut -d = -f 2)"
        if [[ -n "${NEW_SSH_AUTH_SOCK}" ]] && [[ -S "${NEW_SSH_AUTH_SOCK}" ]]; then
            export SSH_AUTH_SOCK="${NEW_SSH_AUTH_SOCK}"
        fi
    fi
}
