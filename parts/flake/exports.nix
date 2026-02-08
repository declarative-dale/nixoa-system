{
  config,
  lib,
  ...
}:
let
  featureNames = config.nixoa.lib.featureNames;
  stackNames = config.nixoa.lib.stackNames;
  mkFeature = config.nixoa.lib.mkFeatureModule;
  mkStack = config.nixoa.lib.mkStackModule;
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
