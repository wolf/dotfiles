if [[ $(uname) =~ .*_NT-10.0 ]] ; then
    IDEA_DIR=$(cygpath --unix "$LOCALAPPDATA/JetBrains/Toolbox/apps/IDEA-U" 2>/dev/null)
    CHARM_DIR=$(cygpath --unix "$LOCALAPPDATA/JetBrains/Toolbox/apps/PyCharm-P" 2>/dev/null)
    IDEA=$(find "${IDEA_DIR}" -name idea64.exe 2>/dev/null)
    CHARM=$(find "${CHARM_DIR}" -name pycharm64.exe 2>/dev/null)

    case $(uname -o) in
        Msys)   alias idea=$(cygpath --mixed "${IDEA}" 2>/dev/null)
                alias charm="$(cygpath --mixed "${CHARM}" 2>/dev/null) &"
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
