export WORKSPACE=/c/dev/active_workspace
export WINDOWSHOME=/c/Users/Wolf
export VAGRANTHOME=/c/dev/vagrant

alias make-tags="$WORKSPACE/k12/tools/scripts/shell/make-tags.sh"
alias fix-wrapping='kill -WINCH $$'

function cdh() { cd "$WINDOWSHOME/$1"; }
function cdw() {
    cd "$WORKSPACE";
    cd $(pwd -P);
    cd "$1";
}
function cdvagrant() { cd "$VAGRANTHOME/$1"; }

function cl_mysql() {
    case $1 in
        local)  DB_HOST=127.0.0.1 ;;
        dev)    DB_HOST=dmilazdb.in.learninga-z.com ;;
        pre)    DB_HOST=pmilazdb.in.learninga-z.com ;;
        post)   DB_HOST=tmilazdb.in.learninga-z.com ;;
    esac

    echo "Connecting to MySQL client on $DB_HOST as ldbuser."
    winpty mysql -h $DB_HOST -P 3306 -u ldbuser -p --prompt="MySQL:$1 [\d]> "
}
