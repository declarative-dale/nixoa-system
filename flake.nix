# SPDX-License-Identifier: Apache-2.0
{
  description = "User configuration flake for NixOA - Entry point for system and user config";

  inputs = {
    # NixOS packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    # Import nixoa-vm as module library
    nixoa-vm = {
      url = "path:/etc/nixos/nixoa/nixoa-vm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Get home-manager from nixoa-vm to ensure consistency
    home-manager.follows = "nixoa-vm/home-manager";
  };

  outputs = { self, nixpkgs, nixoa-vm, home-manager }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};

      # ========================================================================
      # PURE NIX CONFIGURATION (single source of truth)
      # ========================================================================

      # Import configuration.nix which defines userSettings and systemSettings
      config = import ./configuration.nix { inherit lib pkgs; };

      # Extract settings from configuration
      userSettings = config.userSettings;
      systemSettings = config.systemSettings;

      # Read XO server TOML directly from file
      xoTomlData = builtins.readFile ./config.nixoa.toml;

      # ========================================================================
      # EXTRACT CONVENIENCE SCALARS
      # ========================================================================

      hostname = systemSettings.hostname or "nixoa";
      username = systemSettings.username or "xoa";

      # ========================================================================
      # CREATE ARGS BUNDLE
      # ========================================================================

      # This bundle is passed to both NixOS and Home Manager modules
      userArgs = {
        inherit username hostname system;
        inherit userSettings systemSettings;
        inherit xoTomlData;
      };
    in {
      # ========================================================================
      # NIXOS CONFIGURATIONS (Main export - entry point for system)
      # ========================================================================

      nixosConfigurations.${hostname} = lib.nixosSystem {
        inherit system;

        modules = [
          # Hardware configuration - local to this flake
          ./hardware-configuration.nix

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

              # Pass configuration args to home-manager
              extraSpecialArgs = userArgs;

              # Configure home for the admin user
              # Home Manager config is now in this flake, not nixoa-vm
              users.${username} = import ./modules/home.nix;
            };
          }

          # Provide module arguments via _module.args
          # Config data goes here (follows NixOS 25.11 best practices)
          {
            _module.args = {
              inherit xoTomlData;
            };
          }
        ];

        # Pass configuration to all modules via specialArgs
        # Includes flake sources from nixoa-vm and user-specific settings
        specialArgs = userArgs // {
          inherit (nixoa-vm.inputs) xoSrc libvhdiSrc;
        };
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
        };

        apply = {
          type = "app";
          program = toString (pkgs.writeShellScript "apply-config" ''
            ${builtins.readFile ./scripts/apply-config.sh}
          '');
        };

        diff = {
          type = "app";
          program = toString (pkgs.writeShellScript "show-diff" ''
            ${builtins.readFile ./scripts/show-diff.sh}
          '');
        };

        history = {
          type = "app";
          program = toString (pkgs.writeShellScript "history" ''
            ${builtins.readFile ./scripts/history.sh}
          '');
        };
      };
    };
}
