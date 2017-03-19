if [[ $(uname) =~ CYGWIN.* ]] ; then
    export WORKSPACE=/cygdrive/c/kepler/workspace
    export WINDOWSHOME=/cygdrive/c/Users/wolfe
    alias cdw='cd $WORKSPACE'
    alias make-tags="$WORKSPACE/tools/scripts/shell/make-tags.sh"

    alias fix-wrapping='kill -WINCH $$'
else
    function be() {
        sudo -u "$1" -i bash;
    }
fi
