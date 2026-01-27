# SPDX-License-Identifier: Apache-2.0
# Feature toggles
{ ... }:
{
  enableExtras = false; # Enhanced terminal tools with zsh shell (bash used when disabled)
  enableXenGuest = true; # Xen guest agent for better VM integration
  enableXO = true; # Xen Orchestra service
}
