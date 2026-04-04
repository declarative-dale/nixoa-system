# SPDX-License-Identifier: Apache-2.0
# Home session variables
{
  vars,
  ...
}:
{
  home.sessionVariables = {
    NIXOA_SYSTEM_ROOT = vars.repoDir;
    XO_MOUNTS = vars.mountsDir;
  };
}
