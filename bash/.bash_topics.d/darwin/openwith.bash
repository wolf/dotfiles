if [ -z "${SSH_CONNECTION}" ] ; then
    alias fix_open_with='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
fi
