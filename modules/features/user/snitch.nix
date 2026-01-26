# SPDX-License-Identifier: Apache-2.0
# Snitch configuration for the admin user
{
  inputs,
  pkgs,
  vars,
  ...
}:
{
  home-manager.users.${vars.username}.programs.snitch = {
    enable = true;
    package = inputs.snitch.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      defaults = {
        theme = "dracula";
        interval = "2s";
        resolve = true;
      };
    };
  };
}
