# SPDX-License-Identifier: Apache-2.0
# User configuration flake for NixOA - Entry point for system configuration

{
  description = "User configuration flake for NixOA - Entry point for system config";

  inputs = {
    # NixOS packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Note: nixoa-vm should be at /etc/nixos/nixoa-vm
    # If path doesn't exist, clone it: sudo git clone https://codeberg.org/nixoa/nixoa-vm.git /etc/nixos/nixoa-vm
    nixoa-vm = {
      url = "path:/etc/nixos/nixoa-vm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Get home-manager from nixoa-vm to ensure consistency
    home-manager.follows = "nixoa-vm/home-manager";

    # Snitch - network traffic monitoring tool
    snitch.url = "github:karol-broda/snitch";
  };

  outputs = { self, nixpkgs, nixoa-vm, home-manager, snitch }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # ========================================================================
      # NIXOS CONFIGURATIONS (Main export - entry point for system)
      # ========================================================================

      nixosConfigurations.nixoa = lib.nixosSystem {
        inherit system;

        modules = [
          # Hardware configuration - local to this flake
          ./hardware-configuration.nix

          # User configuration - defines all nixoa.* options
          ./configuration.nix

          # Import nixoa-vm module library
          # This provides all system modules (core/, xo/)
          nixoa-vm.nixosModules.default

          # Home Manager NixOS module
          home-manager.nixosModules.home-manager

          # Home Manager configuration
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "bak";

              # Configure home for the admin user
              users.xoa = import ./modules/home.nix;
            };
          }

          # Snitch configuration (Home Manager module)
          {
            home-manager.users.xoa.programs.snitch = {
              enable = true;
              settings = {
                defaults = {
                  theme = "dracula";
                  interval = "2s";
                  resolve = true;
                };
              };
            };
          }
        ];
      };

      # ========================================================================
      # HELPER APPS
      # ========================================================================

      apps.${system} = {
        commit = {
          type = "app";
          program = toString (pkgs.writeShellScript "commit-config" ''
            ${builtins.readFile ./scripts/commit-config.sh}
          '');
          meta = {
            description = "Commit configuration changes to git";
          };
        };

        apply = {
          type = "app";
          program = toString (pkgs.writeShellScript "apply-config" ''
            ${builtins.readFile ./scripts/apply-config.sh}
          '');
          meta = {
            description = "Apply configuration changes to the system";
          };
        };

        diff = {
          type = "app";
          program = toString (pkgs.writeShellScript "show-diff" ''
            ${builtins.readFile ./scripts/show-diff.sh}
          '');
          meta = {
            description = "Show configuration differences";
          };
        };

        history = {
          type = "app";
          program = toString (pkgs.writeShellScript "history" ''
            ${builtins.readFile ./scripts/history.sh}
          '');
          meta = {
            description = "Show configuration commit history";
          };
        };
      };
    };
}
