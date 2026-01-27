# SPDX-License-Identifier: Apache-2.0
# Networking and firewall ports
{ ... }:
{
  allowedTCPPorts = [
    80
    443
  ];

  allowedUDPPorts = [
    # Add UDP ports if needed
  ];
}
