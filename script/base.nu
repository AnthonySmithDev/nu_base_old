source ../env.nu
source ../def.nu
source ../builtin.nu

use ../module/config.nu
use ../module/ghub.nu
use ../module/root/
use ../module/pkg/

def main [] {
  sudo echo "Sudo OK"

  setup_dir
  setup_nu

  if (exists-external apt) {
    try {
      pkg apt update
      pkg apt nala
      pkg apt basic
      pkg apt docker
    }
  }

  pkg bin gum
  pkg bin mods
  pkg bin glow

  pkg bin helix
  pkg bin nushell
  pkg bin starship
  pkg bin zoxide
  pkg bin zellij
  pkg bin yazi

  pkg bin fd
  pkg bin rg
  pkg bin rgr
  pkg bin bat
  pkg bin fzf

  pkg bin eza
  pkg bin gdu
  pkg bin gitu
  pkg bin jless
  pkg bin bottom
  pkg bin lazygit
  pkg bin lazydocker
  pkg bin difftastic
  pkg bin carapace

  pkg bin uv
  pkg bin pnpm

  pkg bin java
  pkg bin node
  pkg bin golang

  pkg sh rust

  config mods
  config nushell
  config helix
  config zellij
  config yazi

  root config helix
  root config nushell
  root config zellij

  setup_zoxide
}

def setup_dir [] {
  mkdir $env.USR_LOCAL_BIN
  mkdir $env.USR_LOCAL_LIB
  mkdir $env.USR_LOCAL_SHARE
  mkdir $env.USR_LOCAL_SOURCE
  mkdir $env.USR_LOCAL_DOWN
  mkdir $env.USR_LOCAL_APK
  mkdir $env.USR_LOCAL_DEB
  mkdir $env.USR_LOCAL_FONT

  mkdir $env.USR_LOCAL_SHARE_BIN
  mkdir $env.USR_LOCAL_SHARE_LIB
  mkdir $env.USR_LOCAL_SHARE_BUILD
  mkdir $env.USR_LOCAL_SHARE_APP_IMAGE

  mkdir $env.LOCAL_BIN
  mkdir $env.LOCAL_SHARE
  mkdir $env.LOCAL_SHARE_FONTS
  mkdir $env.LOCAL_SHARE_APPLICATIONS

  mkdir $env.SYSTEMD_USER_DST

  mkdir $env.TMP_PATH_DIR
  mkdir $env.TMP_PATH_FILE
}

const dirs = [
  ~/.local/nu_base
  ~/nu/nu_base
  ~/nu/nu_work
  ~/nu/nu_home
]

def setup_nu [] {
  $dirs
  | each {path expand}
  | where {path exists}
  | each {|dir| $"source ($dir)/mod.nu"}
  | save --force ~/.source.nu

  touch ~/.env.nu
}

def setup_zoxide [] {
  $dirs
  | each {path expand}
  | where {path exists}
  | each { |dir| ^zoxide add $dir; "OK" }
}
