{
  inputs,
  lib,
  ...
}:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  vars = import ../../config/compose.nix {
    inherit lib pkgs;
  };
in
{
  _module.args = {
    inherit vars;
  };
}
