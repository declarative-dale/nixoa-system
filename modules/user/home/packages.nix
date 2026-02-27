# SPDX-License-Identifier: Apache-2.0
# User packages
{
  inputs,
  lib,
  pkgs,
  vars,
  ...
}:
{
  # Keep heavier user tooling behind the extras switch.
  # snitch is sourced from its flake input and only evaluated when enabled.
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
      inputs.snitch.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
