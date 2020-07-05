if [[ $(uname) =~ CYGWIN.* ]] ; then
    export WORKSPACE=/cygdrive/c/dev/code/git_repo
    export WINDOWSHOME=/cygdrive/c/Users/Wolf

    alias make-tags="$WORKSPACE/tools/scripts/shell/make-tags.sh"
    alias fix-wrapping='kill -WINCH $$'

    eval $(dircolors -b ~/.dir_colors)

    export EDITOR='vim'

    function cdh() { cd "$WINDOWSHOME/$1"; }
    function cdw() { cd "$WORKSPACE/$1"; }

    function cl_mysql() {
        case $1 in
            local)  DB_HOST=127.0.0.1 ;;
            dev)    DB_HOST=dmilazdb.in.learninga-z.com ;;
            pre)    DB_HOST=pmilazdb.in.learninga-z.com ;;
            post)   DB_HOST=tmilazdb.in.learninga-z.com ;;
        esac
    }
else
    function be() {
        sudo -u "$1" -i bash;
    }
fi
