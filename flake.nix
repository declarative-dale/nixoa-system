# SPDX-License-Identifier: Apache-2.0
{
  description = "User configuration flake for NiXOA CE (system + XO config)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Legacy: keep for xo-config.nix module
      systemConfig = import ./modules/system.nix;
      xoToml       = import ./modules/xo-server-config.nix systemConfig;
    in {
      # Export NixOS module (replaces old nixoa.system raw data export)
      nixosModules.default = import ./modules/nixoa-config.nix;

      # Alias for backwards compatibility during transition
      nixosModules.config = self.nixosModules.default;

      # Configuration data for NiXOA CE
      nixoa = {
        # DEPRECATED: Legacy raw data export (kept for xo-config.nix compatibility)
        # New approach: use nixosModules.default
        system = systemConfig;

        # Used by xo-config.nix module in NiXOA CE to generate /etc/xo-server/config.toml
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
