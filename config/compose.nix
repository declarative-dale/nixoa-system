# SPDX-License-Identifier: Apache-2.0
# ============================================================================
# NiXOA Configuration Composition
# ============================================================================
# Edit values in the ./config/ files. This file assembles them into the `vars`
# attribute set consumed by the system flake.
# ============================================================================

{ lib, pkgs, ... }:

let
  importConfig = path: import path { inherit lib pkgs; };
  configParts = [
    (importConfig ./site.nix)
    (importConfig ./platform.nix)
    (importConfig ./features.nix)
    (importConfig ./packages.nix)
    (importConfig ./xo.nix)
    (importConfig ./storage.nix)
  ] ++ lib.optionals (builtins.pathExists ./overrides.nix) [ (importConfig ./overrides.nix) ];
in
lib.foldl' lib.recursiveUpdate { } configParts
