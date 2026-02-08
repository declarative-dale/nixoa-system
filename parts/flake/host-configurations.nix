{
  config,
  inputs,
  ...
}:
let
  moduleArgs = config.nixoa.registry.moduleArgs;
  architecture = config.nixoa.registry.architecture;
  vars = config.nixoa.registry.vars;
in
{
  flake.nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
    system = architecture;
    specialArgs = moduleArgs.specialArgs // { homeArgs = moduleArgs.homeArgs; };
    modules = config.nixoa.lib.stackModules "vm";
  };
}
