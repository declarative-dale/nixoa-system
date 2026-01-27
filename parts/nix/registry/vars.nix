{
  inputs,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  vars = import ../../../configuration.nix {
    inherit lib pkgs;
  };
in
{
  config.flake.registry = {
    inherit vars pkgs lib;
  };
}
