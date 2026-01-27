{
  lib,
  ...
}:
let
  feature = module: { inherit module; };

  foundationFeatures = [
    "foundation-overlays"
    "foundation-determinate"
    "foundation-nix-settings"
  ];

  coreFeatures = [
    "core-appliance"
  ];

  hostFeatures = [
    "host-hardware"
    "host-packages"
    "host-firewall"
  ];

  userFeatures = [
    "user-home-manager"
    "user-snitch"
  ];
in
{
  options.flake.registry = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.flake.registry = {
    features = {
      foundation-overlays = feature ../../../modules/foundation/overlays.nix;
      foundation-determinate = feature ../../../modules/foundation/determinate.nix;
      foundation-nix-settings = feature ../../../modules/foundation/nix-settings.nix;
      core-appliance = feature ../../../modules/core/appliance.nix;
      host-hardware = feature ../../../modules/host/hardware.nix;
      host-packages = feature ../../../modules/host/packages.nix;
      host-firewall = feature ../../../modules/host/firewall.nix;
      user-home-manager = feature ../../../modules/user/home-manager.nix;
      user-snitch = feature ../../../modules/user/snitch.nix;
    };

    stacks = {
      vm = foundationFeatures ++ coreFeatures ++ hostFeatures ++ userFeatures;
    };
  };
}
