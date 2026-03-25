# SPDX-License-Identifier: Apache-2.0
# NiXOA core overlay wiring
{
  inputs,
  ...
}:
{
  nixpkgs.overlays = [ inputs.nixoaCore.overlays.nixoa ];
}
