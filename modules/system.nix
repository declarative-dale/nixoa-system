# SPDX-License-Identifier: Apache-2.0
# System configuration for NiXOA CE
# Reads from ../system-settings.toml

let
  # Read and parse the TOML configuration file
  settingsPath = ../system-settings.toml;
  settingsContent = builtins.readFile settingsPath;
  settings = builtins.fromTOML settingsContent;
in
  settings
