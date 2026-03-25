# SPDX-License-Identifier: Apache-2.0
# Host boot loader policy
{
  lib,
  vars,
  ...
}:
{
  boot.loader.systemd-boot.enable = vars.bootLoader == "systemd-boot";
  boot.loader.efi.canTouchEfiVariables = lib.mkIf (
    vars.bootLoader == "systemd-boot"
  ) vars.efiCanTouchVariables;

  boot.loader.grub = lib.mkIf (vars.bootLoader == "grub") {
    enable = true;
    device = vars.grubDevice;
  };
}
