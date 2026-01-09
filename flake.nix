# SPDX-License-Identifier: Apache-2.0
# User configuration flake for NixOA - Entry point for system configuration

{
  description = "User configuration flake for NixOA - Entry point for system config";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    core = {
      url = "git+https://codeberg.org/NiXOA/core?ref=beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.follows = "core/home-manager";
    snitch.url = "github:karol-broda/snitch";
  };

  ## You will be prompted to trust these keys at first rebuild
  ## Selecting yes bypasses the need to build from source and pulls from binary caches:
  ## - Determinate Systems: determinate-nix installer and FlakeHub packages
  ## - NiXOA Cachix: xen-orchestra-ce and libvhdi
  ## Selecting no requires building from source (20+ minutes extra)
  nixConfig = {
    extra-substituters = [
      "https://install.determinate.systems"
      "https://nixoa.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "nixoa.cachix.org-1:N+GsSSd2yKgj2hx01fMG6Oe7tLfbxEi/V0oZFEB721g="
    ];
  };
  outputs =
    inputs:
    let
      # =====================================================================
      # SYSTEM CONFIGURATION VARIABLES
      # Import settings from centralized settings.nix file
      # =====================================================================
      vars = import ../settings.nix { inherit (inputs.nixpkgs) lib; pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./flake ];

      # Make vars available to all flake outputs
      _module.args = { inherit vars; };
    };
}
