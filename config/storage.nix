# SPDX-License-Identifier: Apache-2.0
# Storage backend settings
{ ... }:
{
  enableNFS = true;
  enableCIFS = true;
  enableVHD = true;
  mountsDir = "/var/lib/xo/mounts";
  sudoNoPassword = true; # Allow xo user to mount without password
}
