# SPDX-License-Identifier: Apache-2.0
{
  description = "User configuration flake for NiXOA CE (system + XO config)";

  # No inputs needed – this flake only returns pure data.
  outputs = { self }:
    let
      systemConfig = import ./modules/system.nix;
      xoToml       = import ./modules/xo-server-config.nix systemConfig;
    in {
      nixoa = {
        # Used by NiXOA CE vars.nix instead of nixoa.toml
        system = systemConfig;

        # Used by a small module in NiXOA CE to generate /etc/xo-server/config.toml
        xoServer.toml = xoToml;
      };
    };
}
