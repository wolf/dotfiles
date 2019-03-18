if [[ $(uname) =~ CYGWIN.* ]] ; then
    export WORKSPACE=/cygdrive/c/kepler/workspace
    export WINDOWSHOME=/cygdrive/c/Users/Wolf

    alias make-tags="$WORKSPACE/tools/scripts/shell/make-tags.sh"
    alias fix-wrapping='kill -WINCH $$'

    eval $(dircolors -b ~/.dir_colors)

    export EDITOR='vim'

    function cdw() {
        cd "$WORKSPACE/$1"
    }

    function cdh() {
        cd "$WINDOWSHOME/$1"
    }
else
    function be() {
        sudo -u "$1" -i bash;
    }
fi
