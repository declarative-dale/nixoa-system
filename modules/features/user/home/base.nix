# SPDX-License-Identifier: Apache-2.0
# Home Manager base settings
{
  vars,
  ...
}:
{
  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.stateVersion = vars.stateVersion;

  programs.home-manager.enable = true;
}
