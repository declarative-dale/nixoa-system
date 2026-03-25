{
  inputs,
  lib,
  ...
}:
let
  site = import ../../config/site.nix { };
  system = site.hostSystem;
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
