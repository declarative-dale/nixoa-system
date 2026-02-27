{
  lib,
  config,
  ...
}:
let
  registry = config.nixoa.registry or { };
  featureNames = builtins.attrNames (registry.features or { });
  stackNames = builtins.attrNames (registry.stacks or { });
  resolveFeature = name: registry.features.${name};

  featureModules = names: map (name: (resolveFeature name).module) names;
  stackModules = name: featureModules registry.stacks.${name};

  mkFeatureModule = name: { imports = featureModules [ name ]; };
  mkStackModule = name: { imports = stackModules name; };
in
{
  # Shared helpers for feature-centric composition.
  options.nixoa.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };

  config.nixoa.lib = {
    inherit
      featureNames
      stackNames
      resolveFeature
      featureModules
      stackModules
      mkFeatureModule
      mkStackModule
      ;
  };
}
