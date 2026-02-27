# SPDX-License-Identifier: Apache-2.0
# Xen Orchestra configuration
{ ... }:
{
  enableXO = true; # Xen Orchestra service
  enableXenGuest = true; # Xen guest agent for better VM integration

  # XO service account (usually no need to change)
  xoUser = "xo";
  xoGroup = "xo";

  xoConfigFile = ../config.nixoa.toml;
  xoHttpHost = "0.0.0.0"; # Used in TLS certificate generation (Subject Alternative Name)

  enableTLS = true;
  enableAutoCert = true; # Automatic self-signed certificate generation
}
