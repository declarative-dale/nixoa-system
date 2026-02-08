# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "User configuration flake for NixOA - Entry point for system config";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./parts);

  nixConfig = {
    extra-substituters = [ "https://xen-orchestra-ce.cachix.org" ];
    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "xen-orchestra-ce.cachix.org-1:WAOajkFLXWTaFiwMbLidlGa5kWB7Icu29eJnYbeMG7E="
    ];
  };

  inputs = {
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "https://flakehub.com/f/nix-community/home-manager/0";
    };
    import-tree.url = "github:vic/import-tree";
    nixoaCore = {
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
        xen-orchestra-ce.follows = "xen-orchestra-ce";
      };
      url = "git+https://codeberg.org/NiXOA/core?ref=beta";
    };
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    snitch = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:karol-broda/snitch";
    };
    xen-orchestra-ce.url = "git+https://codeberg.org/NiXOA/xen-orchestra-ce.git?ref=refs/tags/v6.1.1";
  };

}
