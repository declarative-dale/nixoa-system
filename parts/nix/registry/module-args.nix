{
  config,
  inputs,
  ...
}:
let
  vars = config.nixoa.registry.vars;
in
{
  config.nixoa.registry.moduleArgs = {
    specialArgs = {
      inherit vars inputs;
    };

    homeArgs = {
      inherit vars;
    };
  };
}
