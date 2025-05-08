source ../env.nu
source ../def.nu
source ../builtin.nu

use ../module/config.nu
use ../module/ghub.nu
use ../module/pkg/

def main [] {
  setup_zoxide

  config git
  pkg font FiraCode

  if (exists-external apt) {
    pkg apt brave
    pkg deb discord
    pkg apt flathub

    pkg deb vieb
    pkg apt wezterm
    # pkg deb ghostty-ubuntu

    config vieb
    config wezterm
    # config ghostty desktop
  }

  pkg bin rain
  pkg bin melt
  pkg bin soft
  pkg bin freeze

  pkg bin qrcp
  pkg bin qrrs

  pkg bin task
  pkg bin wsget
  pkg bin broot
  pkg bin rclone
  pkg bin ttyper

  pkg bin zk
  pkg bin omm
  pkg bin taskell

  pkg bin usql
  pkg bin mongosh
  pkg bin vi-mongo

  pkg bin kubectl
  pkg bin kubecolor

  pkg bin github-cli
  pkg bin gitlab-cli

  pkg bin scrcpy

  pkg sh tailscale
}

def --env dev [] {
  env-path $env.GOBIN
  env-path $env.CARGOBIN
  env-path $env.PIPX_BIN_DIR
  env-path $env.NPM_CONFIG_BIN

  pkg go dev
  pkg js dev
  pkg py dev
  pkg cargo dev
}

def setup_zoxide [] {
  ^zoxide add ~/Desktop
  ^zoxide add ~/Documents
  ^zoxide add ~/Downloads
  ^zoxide add ~/Music
  ^zoxide add ~/Pictures
  ^zoxide add ~/Public
  ^zoxide add ~/Templates
  ^zoxide add ~/Videos
}
