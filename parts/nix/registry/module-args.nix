{
  config,
  inputs,
  ...
}:
let
  vars = config.flake.registry.vars;
in
{
  config.flake.registry.moduleArgs = {
    specialArgs = {
      inherit vars inputs;
      nixoa = {
        registry = inputs.nixoaCore.registry;
        lib = inputs.nixoaCore.lib;
      };
    };

    homeArgs = {
      inherit vars;
      nixoa = {
        registry = inputs.nixoaCore.registry;
      };
    };
  };
}
