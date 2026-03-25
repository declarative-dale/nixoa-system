# SPDX-License-Identifier: Apache-2.0
# Extra operator tooling
{
  lib,
  pkgs,
  vars,
  ...
}:
{
  environment.shells = [ pkgs.bashInteractive ] ++ lib.optionals vars.enableExtras [ pkgs.zsh ];

  programs.zsh.enable = vars.enableExtras;
  programs.git.enable = vars.enableExtras;

  programs.direnv = lib.mkIf vars.enableExtras {
    enable = true;
    nix-direnv.enable = true;
  };
}
