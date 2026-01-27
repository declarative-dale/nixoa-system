{
  config,
  inputs,
  ...
}:
let
  argsRegistry = config.flake.registry.args;
  vars = config.flake.registry.vars;
  mkArgs = argsRegistry.mkArgs;

  specialArgs = mkArgs argsRegistry.specialArgsList;
  homeArgs = mkArgs argsRegistry.homeArgsList;
in
{
  flake.nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = specialArgs // { inherit homeArgs; };
    modules = config.flake.lib.stackModules "vm";
  };
}
