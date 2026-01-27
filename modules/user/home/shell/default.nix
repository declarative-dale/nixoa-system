# SPDX-License-Identifier: Apache-2.0
# Shell configuration bundle (directory import)
{ lib, ... }:
let
  dir = ./.;
  entries = builtins.readDir dir;
  names = builtins.attrNames entries;
  isNixFile = name:
    entries.${name} == "regular" && lib.hasSuffix ".nix" name && name != "default.nix";
  imports = map (name: dir + "/${name}") (builtins.filter isNixFile names);
in
{
  inherit imports;
}
