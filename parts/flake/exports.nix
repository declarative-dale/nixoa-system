{
  config,
  lib,
  ...
}:
let
  featureNames = config.flake.lib.featureNames;
  stackNames = config.flake.lib.stackNames;
  mkFeature = config.flake.lib.mkFeatureModule;
  mkStack = config.flake.lib.mkStackModule;
in
{
  flake = {
    nixosModules =
      (lib.genAttrs featureNames mkFeature)
      // (lib.genAttrs stackNames mkStack)
      // {
        default = mkStack "vm";
      };
  };
}
