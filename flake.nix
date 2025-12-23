# SPDX-License-Identifier: Apache-2.0
{
  description = "User configuration flake for NixOA (system + XO config)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
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

      # Hardware configuration path
      hardwareConfigPath = ./hardware-configuration.nix;
    in {
      # ========================================================================
      # CONFIGURATION DATA EXPORTS
      # ========================================================================

      nixoa = {
        # Expose convenience scalars
        inherit hostname;

        # Expose specialArgs bundle for nixoa-vm
        specialArgs = userArgs;
        extraSpecialArgs = userArgs;  # Alias for home-manager

        # XO server TOML data
        xoServer.toml = xoTomlData;
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
