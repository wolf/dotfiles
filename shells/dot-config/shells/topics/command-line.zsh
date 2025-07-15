zvm_config() {
  ZVM_VI_EDITOR=hx
  ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
}

source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
