# SPDX-License-Identifier: Apache-2.0
# Home session variables
{
  vars,
  ...
}:
{
  home.sessionVariables = {
    XO_MOUNTS = vars.mountsDir;
  };
}
