# SPDX-License-Identifier: Apache-2.0
# Core NiXOA appliance stack
{
  inputs,
  ...
}:
{
  imports = [ inputs.nixoaCore.nixosModules.appliance ];
}
