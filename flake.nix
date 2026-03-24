{
  description = "User configuration flake for NiXOA - Entry point for system config";

  outputs =
    inputs:
    builtins.removeAttrs
      (
        (inputs.nixpkgs.lib.evalModules {
          modules = [
            ./modules/dendritic.nix
            ./modules/config.nix
            ./modules/topology.nix
            ./modules/aspects.nix
            ./modules/outputs.nix
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
    flake-aspects.url = "github:vic/flake-aspects";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "https://flakehub.com/f/nix-community/home-manager/0";
    };
    import-tree.url = "github:vic/import-tree";
    nixoaCore.url = "git+https://codeberg.org/NiXOA/core.git?ref=beta";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    snitch = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:karol-broda/snitch";
    };
  };
}
