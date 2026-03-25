# SPDX-License-Identifier: Apache-2.0
# User packages
{
  inputs,
  lib,
  pkgs,
  vars,
  ...
}:
let
  resolvePackage =
    name:
    lib.attrByPath
      (lib.splitString "." name)
      (throw "NiXOA user package '${name}' was not found in pkgs")
      pkgs;
in
{
  # Keep heavier user tooling behind the extras switch.
  # snitch is sourced from its flake input and only evaluated when enabled.
  home.packages =
    vars.userPackages
    ++ map resolvePackage (vars.extraUserPackages or [ ])
    ++ lib.optionals vars.enableExtras [
      pkgs.bat
      pkgs.eza
      pkgs.fd
      pkgs.ripgrep
      pkgs.dust
      pkgs.duf
      pkgs.procs
      pkgs.broot
      pkgs.delta
      pkgs.jq
      pkgs.yq-go
      pkgs.gping
      pkgs.dog
      pkgs.bottom
      pkgs.bandwhich
      pkgs.tealdeer
      pkgs.lazygit
      pkgs.gh
      inputs.snitch.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}
