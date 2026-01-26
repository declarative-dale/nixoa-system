# SPDX-License-Identifier: Apache-2.0
# Home Manager NixOS integration
{
  inputs,
  vars,
  homeArgs ? { },
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = homeArgs;
    sharedModules = [ inputs.snitch.homeManagerModules.default ];
    users.${vars.username} = import ./home.nix;
  };
}
