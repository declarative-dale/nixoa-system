# SPDX-License-Identifier: Apache-2.0
# User configuration flake for NixOA - Entry point for system configuration

{
  description = "User configuration flake for NixOA - Entry point for system config";

  inputs = {
    #Determinate Nix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    
    # NixOS packages
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    # Flakehub Mirror
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # NixOS, current stable

    # nixoa-vm from Codeberg repository
    nixoa-vm = {
      url = "git+https://codeberg.org/NiXOA/core?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Get home-manager from nixoa-vm to ensure consistency
    home-manager.follows = "nixoa-vm/home-manager";

    # Snitch - network traffic monitoring tool
    snitch.url = "github:karol-broda/snitch";
  };

  outputs = { self, nixpkgs, determinate, nixoa-vm, home-manager, snitch }:
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
          
          # Determinate Nix Module
          determinate.nixosModules.default
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

              # Import snitch home-manager module for xoa user
              sharedModules = [ snitch.homeManagerModules.default ];

              # Configure home for the admin user
              users.xoa = import ./modules/home.nix;
            };
          }

          # Snitch configuration (Home Manager module)
          {
            home-manager.users.xoa.programs.snitch = {
              enable = true;
              package = snitch.packages.${system}.default;
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
