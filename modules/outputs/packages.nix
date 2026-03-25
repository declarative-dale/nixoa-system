{
  inputs,
  vars,
  ...
}:
let
  system = vars.hostSystem;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  nixoaMenu = pkgs.callPackage ../../pkgs/nixoa-menu/package.nix { };
in
{
  flake.packages.${system}.nixoa-menu = nixoaMenu;
}
