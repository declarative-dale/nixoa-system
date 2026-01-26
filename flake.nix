# SPDX-License-Identifier: Apache-2.0
# User configuration flake for NixOA - Entry point for system configuration

{
  description = "User configuration flake for NixOA - Entry point for system config";

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-file.url = "github:vic/flake-file";
    import-tree.url = "github:vic/import-tree";
    nixoaCore = {
      url = "git+https://codeberg.org/NiXOA/core?ref=beta";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    snitch = {
      url = "github:karol-broda/snitch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./parts);
}
