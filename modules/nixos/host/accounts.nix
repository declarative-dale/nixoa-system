# SPDX-License-Identifier: Apache-2.0
# Host administrator account
{
  lib,
  vars,
  ...
}:
let
  homeDir = "/home/${vars.username}";
  repoDir = vars.repoDir or "${homeDir}/system";
in
{
  users.mutableUsers = false;

  systemd.tmpfiles.rules = [
    "d ${homeDir} 0755 ${vars.username} users -"
    "d ${homeDir}/.ssh 0700 ${vars.username} users -"
  ];

  system.activationScripts.nixoa-managed-home = lib.stringAfter [ "users" ] ''
    if [ -d ${lib.escapeShellArg homeDir} ]; then
      chown ${vars.username}:users ${lib.escapeShellArg homeDir}
    fi

    if [ -d ${lib.escapeShellArg repoDir} ]; then
      chown -R ${vars.username}:users ${lib.escapeShellArg repoDir}
    fi
  '';

  users.users.${vars.username} = {
    isNormalUser = true;
    home = homeDir;
    createHome = true;
    description = "NiXOA administrator";
    group = "users";
    extraGroups = [
      "systemd-journal"
    ];
    hashedPassword = "!";
    openssh.authorizedKeys.keys = vars.sshKeys;
  };
}
