# NixOS system configurations
{ inputs, ... }:
{
  flake = {
    nixosConfigurations.nixoa = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        # Set the host platform
        { nixpkgs.hostPlatform = "x86_64-linux"; }

        # Hardware configuration
        ../hardware-configuration.nix

        # User configuration
        ../configuration.nix

        # Determinate Nix Module
        inputs.determinate.nixosModules.default

        # Import core module library
        inputs.core.nixosModules.default

        # Xen guest agent configuration (system-specific)
        ../modules/xen-guest.nix

        # Home Manager NixOS module
        inputs.home-manager.nixosModules.home-manager

        # Home Manager configuration
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";
            sharedModules = [ inputs.snitch.homeManagerModules.default ];
            users.xoa = import ../modules/home.nix;
          };
        }

        # Snitch configuration
        ({ pkgs, ... }: {
          home-manager.users.xoa.programs.snitch = {
            enable = true;
            package = inputs.snitch.packages.${pkgs.system}.default;
            settings = {
              defaults = {
                theme = "dracula";
                interval = "2s";
                resolve = true;
              };
            };
          };
        })
      ];
    };
  };
}
