{
  config,
  inputs,
  lib,
  ...
}:
let
  mkArgs = list: lib.foldl' (acc: next: acc // next) { } list;
  vars = config.flake.registry.vars;
in
{
  config.flake.registry.args = {
    inherit mkArgs;

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
  };
}
