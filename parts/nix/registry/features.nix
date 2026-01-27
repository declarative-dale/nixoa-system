{
  lib,
  ...
}:
let
  feature = module: { inherit module; };

  commonModules = [
    ../../../modules/features/foundation/args.nix
  ];

  foundationFeatures = [
    "foundation-platform"
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
    modules = {
      common = commonModules;
    };

    features = {
      foundation-platform = feature ../../../modules/features/foundation/platform.nix;
      foundation-overlays = feature ../../../modules/features/foundation/overlays.nix;
      foundation-determinate = feature ../../../modules/features/foundation/determinate.nix;
      foundation-nix-settings = feature ../../../modules/features/foundation/nix-settings.nix;
      core-appliance = feature ../../../modules/features/core/appliance.nix;
      host-hardware = feature ../../../modules/features/host/hardware.nix;
      host-packages = feature ../../../modules/features/host/packages.nix;
      host-firewall = feature ../../../modules/features/host/firewall.nix;
      user-home-manager = feature ../../../modules/features/user/home-manager.nix;
      user-snitch = feature ../../../modules/features/user/snitch.nix;
    };

    stacks = {
      vm = foundationFeatures ++ coreFeatures ++ hostFeatures ++ userFeatures;
    };
  };
}
