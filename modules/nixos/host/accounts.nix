# SPDX-License-Identifier: Apache-2.0
# Host administrator account
{
  lib,
  pkgs,
  vars,
  ...
}:
{
  systemd.tmpfiles.rules = [
    "d /home/${vars.username}/.ssh 0700 ${vars.username} users -"
  ];

  users.users.${vars.username} = {
    isNormalUser = true;
    description = "NiXOA administrator";
    createHome = true;
    home = "/home/${vars.username}";
    shell = if vars.enableExtras then pkgs.zsh else pkgs.bashInteractive;
    extraGroups = [
      "wheel"
      "systemd-journal"
    ];
    hashedPassword = "!";
    openssh.authorizedKeys.keys = vars.sshKeys;
  };

  environment.shells = [ pkgs.bashInteractive ] ++ lib.optionals vars.enableExtras [ pkgs.zsh ];
  programs.zsh.enable = vars.enableExtras;
}
