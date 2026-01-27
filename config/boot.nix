# SPDX-License-Identifier: Apache-2.0
# Boot configuration
{ ... }:
{
  bootLoader = "systemd-boot"; # Options: "systemd-boot" or "grub"
  efiCanTouchVariables = true;
  grubDevice = ""; # Set to device path (e.g., "/dev/sda") if using GRUB
}
