# SPDX-License-Identifier: Apache-2.0
# Shared module arguments for feature-centric composition
{
  inputs ? { },
  vars ? { },
  ...
}:
{
  _module.args = {
    inherit inputs vars;
  };
}
