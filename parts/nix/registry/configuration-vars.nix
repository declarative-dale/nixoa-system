{
  config,
  inputs,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
  pkgs = inputs.nixpkgs.legacyPackages.${config.flake.registry.architecture};
  vars = import ../../../configuration.nix {
    inherit lib pkgs;
  };
in
{
  config.flake.registry = {
    inherit vars pkgs lib;
  };
}
