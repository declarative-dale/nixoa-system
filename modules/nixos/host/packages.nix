# SPDX-License-Identifier: Apache-2.0
# System packages from settings
{
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

  nixoaMenu = pkgs.callPackage ../../../pkgs/nixoa-menu/package.nix { };
in
{
  environment.systemPackages =
    vars.systemPackages
    ++ map resolvePackage (vars.extraSystemPackages or [ ])
    ++ [ nixoaMenu ];

  # Allow unfree packages needed by core/system package sets.
  nixpkgs.config.allowUnfree = true;
}
