{
  inputs,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
  # Avoid depending on nixoa.registry during registry construction.
  architecture = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${architecture};
  vars = import ../../../configuration.nix {
    inherit lib pkgs;
  };
in
{
  config.nixoa.registry = {
    inherit vars pkgs lib;
  };
}
