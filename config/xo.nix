# SPDX-License-Identifier: Apache-2.0
# Xen Orchestra service account and runtime configuration
{ ... }:
{
  # XO service account (usually no need to change)
  xoUser = "xo";
  xoGroup = "xo";

  xoConfigFile = ../config.nixoa.toml;
  xoHttpHost = "0.0.0.0"; # Used in TLS certificate generation (Subject Alternative Name)

  enableTLS = true;
  enableAutoCert = true; # Automatic self-signed certificate generation
}
