# SPDX-License-Identifier: Apache-2.0
# Host identity and primary user settings
{ ... }:
{
  hostSystem = "x86_64-linux";
  hostname = "nixoa";
  timezone = "Europe/Paris";
  stateVersion = "25.11"; # Don't change this after initial installation

  username = "nixoa";
  sshKeys = [
    # Add your SSH public keys here, one per line
    # Example: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@hostname"
  ];
}
