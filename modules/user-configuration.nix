# SPDX-License-Identifier: Apache-2.0
# ============================================================================
# NiXOA Settings - Centralized Configuration (composed)
# ============================================================================
# Edit values in the ./config/ files. This file assembles them into a single
# attribute set consumed by the system flake.
# ============================================================================

{ lib, pkgs, ... }:

let
  importConfig = path: import path { inherit lib pkgs; };
  configParts = [
    (importConfig ../config/settings.nix)
    (importConfig ../config/packages.nix)
    (importConfig ../config/xo.nix)
    (importConfig ../config/storage.nix)
  ];
in
lib.foldl' lib.recursiveUpdate { } configParts
