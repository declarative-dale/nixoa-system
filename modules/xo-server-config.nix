# SPDX-License-Identifier: Apache-2.0
# Extract raw TOML from [nixoa] section for /etc/xo-server/config.nixoa.toml
# This generates a minimal override config that XO loads alongside its defaults

systemConfig:
let
  # Read and parse the XO server settings TOML
  xoSettingsPath = ../xo-server-settings.toml;

  # Check if file exists
  xoSettings =
    if !builtins.pathExists xoSettingsPath then
      builtins.throw ''
        user-config: xo-server-settings.toml is missing!

        Please ensure the file exists at: ${toString xoSettingsPath}
      ''
    else
      builtins.fromTOML (builtins.readFile xoSettingsPath);

  # Extract raw TOML from [nixoa] section
  nixoaRawToml = xoSettings.nixoa.raw_toml or (builtins.throw ''
    user-config: [nixoa] section with raw_toml is missing in xo-server-settings.toml!

    Please add a [nixoa] section:
    [nixoa]
    raw_toml = '''
    # Your config here
    '''
  '');

  # Filter out commented lines (lines starting with # after optional whitespace)
  # Split into lines, filter out empty and commented lines
  # Note: builtins.split returns alternating strings and match groups (lists)
  # We need to filter to strings only, then filter out empty/commented lines
  lines = builtins.filter
    (line: line != "" && !(builtins.match "^[[:space:]]*#.*" line != null))
    (builtins.filter builtins.isString (builtins.split "\n" nixoaRawToml));

  # Join back into text
  filteredToml = builtins.concatStringsSep "\n" lines;
in
  # Return raw text string, not parsed TOML
  filteredToml
