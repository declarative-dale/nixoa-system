# SPDX-License-Identifier: Apache-2.0
# Home Manager feature set (directory import)
{ lib, ... }:
let
  dir = ./.;
  entries = builtins.readDir dir;
  names = builtins.attrNames entries;
  isNixFile = name:
    entries.${name} == "regular" && lib.hasSuffix ".nix" name && name != "default.nix";
  isDefaultDir = name:
    entries.${name} == "directory" && builtins.pathExists (dir + "/${name}/default.nix");
  importable = name: isNixFile name || isDefaultDir name;
  imports = map (name: dir + "/${name}") (builtins.filter importable names);
in
{
  inherit imports;
}
