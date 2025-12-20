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
      # TOML PARSING (single source of truth)
      # ========================================================================

      # Parse system-settings.toml
      settingsPath = ./system-settings.toml;
      settingsContent = builtins.readFile settingsPath;
      nixoaCfg = builtins.fromTOML settingsContent;

      # Parse xo-server-settings.toml
      xoSettingsPath = ./xo-server-settings.toml;
      xoServerCfg =
        if builtins.pathExists xoSettingsPath
        then builtins.fromTOML (builtins.readFile xoSettingsPath)
        else {};

      # Extract XO server TOML text (filtered)
      xoTomlData = import ./modules/xo-server-config.nix;

      # ========================================================================
      # EXTRACT CONVENIENCE SCALARS
      # ========================================================================

      hostname = nixoaCfg.hostname or "nixoa";
      username = nixoaCfg.username or "xoa";

      # ========================================================================
      # CREATE ARGS BUNDLE
      # ========================================================================

      # This bundle is passed to both NixOS and Home Manager modules
      userArgs = {
        inherit nixoaCfg xoServerCfg username hostname system;
        # Add xoTomlData for backwards compatibility with xo-config.nix
        inherit xoTomlData;
      };

      # Hardware configuration path
      hardwareConfigPath = ./hardware-configuration.nix;
    in {
      # ========================================================================
      # NIXOS MODULES
      # ========================================================================

      nixosModules.default = import ./nixos;

      nixosModules.hardware =
        if builtins.pathExists hardwareConfigPath
        then import hardwareConfigPath
        else builtins.throw ''
          user-config: hardware-configuration.nix is missing!

          Please copy your hardware configuration:
            sudo cp /etc/nixos/hardware-configuration.nix /etc/nixos/nixoa/user-config/

          Or generate it:
            sudo nixos-generate-config --show-hardware-config > /etc/nixos/nixoa/user-config/hardware-configuration.nix
        '';

      # ========================================================================
      # HOME MANAGER MODULES
      # ========================================================================

      homeManagerModules.default = import ./home;

      # ========================================================================
      # LEGACY CONFIGURATION DATA (backwards compatibility)
      # ========================================================================

      nixoa = {
        # Expose convenience scalars
        inherit hostname;

        # Expose specialArgs bundle for nixoa-vm
        specialArgs = userArgs;
        extraSpecialArgs = userArgs;  # Alias for home-manager

        # Legacy exports (for smooth transition)
        system = nixoaCfg;
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
