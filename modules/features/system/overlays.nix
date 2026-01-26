# SPDX-License-Identifier: Apache-2.0
# Core overlay wiring
{
  inputs,
  ...
}:
{
  nixpkgs.overlays = [ inputs.nixoaCore.overlays.nixoa ];
}
