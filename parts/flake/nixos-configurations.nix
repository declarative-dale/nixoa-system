{
  config,
  inputs,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  vars = import ../../settings.nix {
    inherit lib;
    inherit pkgs;
  };

  specialArgsList = [
    { inherit vars; }
    { inherit inputs; }
    {
      nixoa = {
        registry = inputs.nixoaCore.registry;
        lib = inputs.nixoaCore.lib;
      };
    }
  ];

  homeArgsList = [
    { inherit vars; }
    {
      nixoa = {
        registry = inputs.nixoaCore.registry;
      };
    }
  ];

  specialArgs = lib.foldl' (acc: next: acc // next) { } specialArgsList;
  homeArgs = lib.foldl' (acc: next: acc // next) { } homeArgsList;
in
{
  flake.nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = specialArgs // {
      inherit homeArgs;
    };
    modules = config.flake.lib.stackModules "vm";
  };
}
