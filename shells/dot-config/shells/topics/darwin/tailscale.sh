if [ -d /Applications/Tailscale.app ]; then
  PATH="$PATH:/Applications/Tailscale.app/Contents/MacOS"
  alias tailscale=Tailscale
fi
