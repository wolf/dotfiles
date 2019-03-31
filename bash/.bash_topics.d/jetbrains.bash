if [[ $(uname) =~ .*_NT-10.0 ]] ; then
    IDEA_DIR=$(cygpath --unix "$LOCALAPPDATA/JetBrains/Toolbox/apps/IDEA-U")
    CHARM_DIR=$(cygpath --unix "$LOCALAPPDATA/JetBrains/Toolbox/apps/PyCharm-P")
    IDEA=$(find "${IDEA_DIR}" -name idea64.exe 2>/dev/null)
    CHARM=$(find "${CHARM_DIR}" -name pycharm64.exe 2>/dev/null)

    case $(uname -o) in
        Msys)   alias idea=$(cygpath --mixed "${IDEA}")
                alias charm=$(cygpath --mixed "${CHARM} &")
                ;;
        Cygwin) alias idea="${IDEA}"
                alias charm="${CHARM} &"
                ;;
    esac

    unset IDEA_DIR
    unset CHARM_DIR
    unset IDEA
    unset CHARM
fi
