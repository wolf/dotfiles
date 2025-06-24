if [ -d /Applications/Kaleidoscope.app ] ; then
  # Yes, I alter `$PATH` here, but only to run an interactive script.
  # Therefore, this topic only needs to be sourced in interactive shells.
  export PATH="${PATH}:/Applications/Kaleidoscope.app/Contents/MacOS"
fi
