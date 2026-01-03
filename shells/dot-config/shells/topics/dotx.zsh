#compdef dotx

_dotx_completion() {
  eval $(env _TYPER_COMPLETE_ARGS="${words[1,$CURRENT]}" _DOTX_COMPLETE=complete_zsh dotx)
}

compdef _dotx_completion dotx
