if [[ $(uname) =~ .*_NT-10.0 ]] ; then
    IDEA_DIR=$(cygpath --unix "$LOCALAPPDATA/JetBrains/Toolbox/apps/IDEA-U")
    IDEA=$(find "${IDEA_DIR}" -name idea64.exe 2>/dev/null)

    case $(uname -o) in
        Msys)   alias idea=$(cygpath --mixed "${IDEA}") ;;
        Cygwin) alias idea="${IDEA}" ;;
    esac

    unset IDEA_DIR
    unset IDEA
fi
