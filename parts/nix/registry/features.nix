{
  lib,
  ...
}:
let
  feature = module: { inherit module; };

  commonModules = [
    ../../../modules/features/shared/args.nix
  ];

  foundationFeatures = [
    "foundation-platform"
    "foundation-overlays"
    "foundation-determinate"
  ];

  systemFeatures = [
    "core-appliance"
    "hardware"
    "system-packages"
    "system-firewall"
  ];

  virtualizationFeatures = [
    "virtualization-xen-guest"
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
      foundation-platform = feature ../../../modules/features/system/platform.nix;
      foundation-overlays = feature ../../../modules/features/system/overlays.nix;
      foundation-determinate = feature ../../../modules/features/system/determinate.nix;
      core-appliance = feature ../../../modules/features/system/core-appliance.nix;
      hardware = feature ../../../modules/features/system/hardware.nix;
      system-packages = feature ../../../modules/features/system/packages.nix;
      system-firewall = feature ../../../modules/features/system/firewall.nix;
      virtualization-xen-guest = feature ../../../modules/features/virtualization/xen-guest.nix;
      user-home-manager = feature ../../../modules/features/user/home-manager.nix;
      user-snitch = feature ../../../modules/features/user/snitch.nix;
    };

    stacks = {
      vm = foundationFeatures ++ systemFeatures ++ virtualizationFeatures ++ userFeatures;
    };
  };
}
