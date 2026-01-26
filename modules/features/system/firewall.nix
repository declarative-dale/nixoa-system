# SPDX-License-Identifier: Apache-2.0
# Firewall configuration from settings
{
  vars,
  ...
}:
{
  networking.firewall.allowedTCPPorts = vars.allowedTCPPorts;
}
