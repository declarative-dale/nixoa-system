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

      systemConfig = import ./modules/system.nix;
      xoToml       = import ./modules/xo-server-config.nix systemConfig;
    in {
      # Configuration data for NiXOA CE
      nixoa = {
        # Used by NiXOA CE vars.nix instead of nixoa.toml
        system = systemConfig;

        # Used by a small module in NiXOA CE to generate /etc/xo-server/config.toml
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
