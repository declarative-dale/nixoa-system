{
  inputs,
  vars,
  ...
}:
let
  system = vars.hostSystem;
  nixoaMenu = inputs.nixoaCore.packages.${system}.nixoa-menu;
in
{
  flake.packages.${system}.nixoa-menu = nixoaMenu;
}
