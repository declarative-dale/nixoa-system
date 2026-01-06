# NixOS system configurations
{ inputs, vars, ... }:
{
  flake = {
    # Use hostname from vars instead of hardcoding "nixoa"
    nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
      # Pass vars to all modules via specialArgs
      specialArgs = { inherit vars; };

      modules = [
        # Set the host platform
        { nixpkgs.hostPlatform = "x86_64-linux"; }

        # Hardware configuration
        ../hardware-configuration.nix

        # Determinate Nix Module
        inputs.determinate.nixosModules.default

        # Import core module library
        inputs.core.nixosModules.default

        # Xen guest agent configuration (system-specific)
        ../modules/xen-guest.nix

        # Autocert configuration (system-specific)
        ../modules/autocert.nix

        # Home Manager NixOS module
        inputs.home-manager.nixosModules.home-manager

        # Home Manager configuration
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "bak";

            # Pass vars to home-manager modules
            extraSpecialArgs = { inherit vars; };

            sharedModules = [ inputs.snitch.homeManagerModules.default ];

            # Use username from vars instead of hardcoding "xoa"
            users.${vars.username} = import ../modules/home.nix;
          };
        }

        # Snitch configuration
        ({ pkgs, ... }: {
          # Use username from vars instead of hardcoding "xoa"
          home-manager.users.${vars.username}.programs.snitch = {
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

        # Additional networking configuration from vars
        {
          networking.firewall.allowedTCPPorts = vars.allowedTCPPorts;
        }
      ];
    };
  };
}
