# SPDX-License-Identifier: Apache-2.0
# User configuration flake for NixOA - Entry point for system configuration

{
  description = "User configuration flake for NixOA - Entry point for system config";

  inputs = {
    # Flakeparts for modular flake structure
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Determinate Nix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    # NixOS packages
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Flakehub Mirror
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0"; # NixOS, current stable

    # Core module library from Codeberg repository
    core = {
      url = "git+https://codeberg.org/NiXOA/core?ref=beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Get home-manager from core to ensure consistency
    home-manager.follows = "core/home-manager";

    # Snitch - network traffic monitoring tool
    snitch.url = "github:karol-broda/snitch";
  };

  outputs = inputs @ { self, flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      flake = {
        # ========================================================================
        # NIXOS CONFIGURATIONS (Main export - entry point for system)
        # ========================================================================

        nixosConfigurations.nixoa = nixpkgs.lib.nixosSystem {
          modules = [
            # Set the host platform (replaces deprecated 'system' attribute)
            { nixpkgs.hostPlatform = "x86_64-linux"; }

            # Hardware configuration - local to this flake
            ./hardware-configuration.nix

            # User configuration - defines all nixoa.* options
            ./configuration.nix

            # Determinate Nix Module
            inputs.determinate.nixosModules.default

            # Import core module library
            # This provides all system modules (core/, xo/)
            inputs.core.nixosModules.default

            # Xen guest agent configuration (system-specific)
            ./modules/xen-guest.nix

            # Home Manager NixOS module
            inputs.home-manager.nixosModules.home-manager

            # Home Manager configuration
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "bak";

                # Import snitch home-manager module for xoa user
                sharedModules = [ inputs.snitch.homeManagerModules.default ];

                # Configure home for the admin user
                users.xoa = import ./modules/home.nix;
              };
            }

            # Snitch configuration (Home Manager module)
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

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # ========================================================================
        # HELPER APPS
        # ========================================================================

        apps = {
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
    };
}
