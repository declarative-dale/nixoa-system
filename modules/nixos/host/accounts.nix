# SPDX-License-Identifier: Apache-2.0
# Host administrator account
{
  vars,
  ...
}:
{
  systemd.tmpfiles.rules = [
    "d /home/${vars.username}/.ssh 0700 ${vars.username} users -"
  ];

  users.users.${vars.username} = {
    description = "NiXOA administrator";
    extraGroups = [
      "systemd-journal"
    ];
    hashedPassword = "!";
    openssh.authorizedKeys.keys = vars.sshKeys;
  };
}
