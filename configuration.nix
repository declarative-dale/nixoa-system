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
  parts = [
    (importConfig ./config/identity.nix)
    (importConfig ./config/users.nix)
    (importConfig ./config/features.nix)
    (importConfig ./config/packages.nix)
    (importConfig ./config/networking.nix)
    (importConfig ./config/xo.nix)
    (importConfig ./config/boot.nix)
    (importConfig ./config/storage.nix)
  ];
in
lib.foldl' lib.recursiveUpdate { } parts
