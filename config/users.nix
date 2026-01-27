# SPDX-License-Identifier: Apache-2.0
# User accounts and access
{ ... }:
{
  username = "xoa";
  sshKeys = [
    # Add your SSH public keys here, one per line
    # Example: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@hostname"
  ];

  # XO service account (usually no need to change)
  xoUser = "xo";
  xoGroup = "xo";
}
