{
  description = "User configuration flake for NiXOA - Entry point for system config";

  outputs =
    inputs:
    builtins.removeAttrs
      (
        (inputs.nixpkgs.lib.evalModules {
          modules = [
            ./modules/den.nix
            ./modules/vars
            ./modules/schema
            ./modules/topology
            ./modules/aspects
            ./modules/outputs
          ];
          specialArgs = { inherit inputs; };
        }).config.flake
      )
      [ "denful" ];

  nixConfig = {
    extra-substituters = [ "https://xen-orchestra-ce.cachix.org" ];
    extra-trusted-public-keys = [
      "xen-orchestra-ce.cachix.org-1:WAOajkFLXWTaFiwMbLidlGa5kWB7Icu29eJnYbeMG7E="
    ];
  };

  inputs = {
    den.url = "github:vic/den";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "https://flakehub.com/f/nix-community/home-manager/0";
    };
    nixoaCore.url = "git+https://codeberg.org/NiXOA/core.git?ref=beta";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    snitch = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:karol-broda/snitch";
    };
  };
}
