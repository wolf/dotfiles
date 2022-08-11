if [ -z "${SSH_CONNECTION}" ] ; then
    alias fix_open_with='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user' # fix_open_with : clean up the Finder's "Open With" menu when it gets wonky
fi
