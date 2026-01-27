# SPDX-License-Identifier: Apache-2.0
# User packages
{
  lib,
  pkgs,
  vars,
  ...
}:
{
  home.packages =
    with pkgs;
    (
      vars.userPackages
    )
    ++ lib.optionals vars.enableExtras [
      bat
      eza
      fd
      ripgrep
      dust
      duf
      procs
      broot
      delta
      jq
      yq-go
      gping
      dog
      bottom
      bandwhich
      tealdeer
      lazygit
      gh
    ];
}
