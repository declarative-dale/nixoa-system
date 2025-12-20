# SPDX-License-Identifier: Apache-2.0
# XO Server configuration file generation
# Generates /etc/xo-server/config.nixoa.toml from parsed TOML

{ pkgs, xoTomlData ? null, ... }:

{
  # Generate the XO server override configuration file
  config.environment.etc."xo-server/config.nixoa.toml" = {
    text = if xoTomlData != null then xoTomlData else "";
    mode = "0644";
  };
}
