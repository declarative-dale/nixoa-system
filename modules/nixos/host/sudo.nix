# SPDX-License-Identifier: Apache-2.0
# Administrator sudo policy
{
  vars,
  ...
}:
{
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;

    extraRules = [
      {
        users = [ vars.username ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
