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

      # Legacy: keep for xo-config.nix module
      systemConfig = import ./modules/system.nix;
      xoToml       = import ./modules/xo-server-config.nix systemConfig;

      # Hardware configuration path
      hardwareConfigPath = ./hardware-configuration.nix;
    in {
      # Export NixOS module (replaces old nixoa.system raw data export)
      nixosModules.default = import ./modules/nixoa-config.nix;

      # Export hardware configuration module
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

      # Alias for backwards compatibility during transition
      nixosModules.config = self.nixosModules.default;

      # Configuration data for NixOA
      nixoa = {
        # DEPRECATED: Legacy raw data export (kept for xo-config.nix compatibility)
        # New approach: use nixosModules.default
        system = systemConfig;

        # Used by xo-config.nix module in nixoa-vm to generate /etc/xo-server/config.toml
        xoServer.toml = xoToml;
      };

      # Helper apps for config management
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
