# SPDX-License-Identifier: Apache-2.0
# Feature toggles layered onto the core appliance
{ ... }:
{
  enableExtras = false; # Enhanced terminal tools and zsh profile
  enableXO = true; # Xen Orchestra service
  enableXenGuest = true; # Xen guest agent for better VM integration
}
