# SPDX-License-Identifier: Apache-2.0
# System packages from settings
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
      (throw "NiXOA system package '${name}' was not found in pkgs")
      pkgs;
  nixoaMenu = inputs.nixoaCore.packages.${pkgs.stdenv.hostPlatform.system}.nixoa-menu;
in
{
  environment.systemPackages =
    vars.systemPackages
    ++ map resolvePackage (vars.extraSystemPackages or [ ])
    ++ [ nixoaMenu ];

  # Allow unfree packages needed by core/system package sets.
  nixpkgs.config.allowUnfree = true;
}
