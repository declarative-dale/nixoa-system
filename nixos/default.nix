# SPDX-License-Identifier: Apache-2.0
# NixOS modules bundle import
# Automatically imports all .nix files in this directory (except default.nix)
{ lib, ... }:

let
  dir = ./.;
  names = builtins.attrNames (builtins.readDir dir);

  nixFiles =
    builtins.filter (n:
      lib.hasSuffix ".nix" n && n != "default.nix"
    ) names;
in
{
  imports = map (n: dir + "/${n}") nixFiles;
}
