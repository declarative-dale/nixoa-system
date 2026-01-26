{
  inputs,
  ...
}:
{
  flake.modules.nixos.nixoaSystem =
    { pkgs, vars, ... }:
    {
      imports = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        { nixpkgs.overlays = [ inputs.nixoaCore.overlays.nixoa ]; }
        inputs.determinate.nixosModules.default
        inputs.nixoaCore.nixosModules.appliance
        ../../hardware-configuration.nix
        ../../modules/xen-guest.nix
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        extraSpecialArgs = { inherit vars; };
        sharedModules = [ inputs.snitch.homeManagerModules.default ];
        users.${vars.username} = import ../../modules/home.nix;
      };

      home-manager.users.${vars.username}.programs.snitch = {
        enable = true;
        package = inputs.snitch.packages.${pkgs.stdenv.hostPlatform.system}.default;
        settings = {
          defaults = {
            theme = "dracula";
            interval = "2s";
            resolve = true;
          };
        };
      };

      networking.firewall.allowedTCPPorts = vars.allowedTCPPorts;
      environment.systemPackages = vars.systemPackages;
    };
}
