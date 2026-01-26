# SPDX-License-Identifier: Apache-2.0
# System packages from settings
{
  vars,
  ...
}:
{
  environment.systemPackages = vars.systemPackages;

  # Allow unfree packages needed by core/system package sets.
  nixpkgs.config.allowUnfree = true;
}
