{
  config,
  inputs,
  ...
}:
let
  moduleArgs = config.flake.registry.moduleArgs;
  architecture = config.flake.registry.architecture;
  vars = config.flake.registry.vars;
in
{
  flake.nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
    system = architecture;
    specialArgs = moduleArgs.specialArgs // { homeArgs = moduleArgs.homeArgs; };
    modules = config.flake.lib.stackModules "vm";
  };
}
