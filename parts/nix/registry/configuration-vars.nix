{
  inputs,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
  # Avoid depending on flake.registry during registry construction.
  architecture = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${architecture};
  vars = import ../../../configuration.nix {
    inherit lib pkgs;
  };
in
{
  config.flake.registry = {
    inherit vars pkgs lib;
  };
}
