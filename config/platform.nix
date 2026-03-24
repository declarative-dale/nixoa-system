# SPDX-License-Identifier: Apache-2.0
# Host platform settings: boot loader and firewall
{ ... }:
{
  bootLoader = "systemd-boot"; # Options: "systemd-boot" or "grub"
  efiCanTouchVariables = true;
  grubDevice = ""; # Set to device path (e.g. "/dev/sda") if using GRUB

  allowedTCPPorts = [
    80
    443
  ];

  allowedUDPPorts = [
    # Add UDP ports if needed
  ];
}
