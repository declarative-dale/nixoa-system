# SPDX-License-Identifier: Apache-2.0
# Host-level system settings (identity, users, boot, networking)
{ ... }:
{
  # Identity
  hostname = "nixoa";
  timezone = "UTC";
  stateVersion = "25.11"; # Don't change this after initial installation

  # User
  username = "xoa";
  sshKeys = [
    # Add your SSH public keys here, one per line
    # Example: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@hostname"
  ];

  # Feature switches
  enableExtras = false; # Enhanced terminal tools with zsh shell (bash used when disabled)

  # Boot
  bootLoader = "systemd-boot"; # Options: "systemd-boot" or "grub"
  efiCanTouchVariables = true;
  grubDevice = ""; # Set to device path (e.g., "/dev/sda") if using GRUB

  # Networking / firewall
  allowedTCPPorts = [
    80
    443
  ];

  allowedUDPPorts = [
    # Add UDP ports if needed
  ];
}
