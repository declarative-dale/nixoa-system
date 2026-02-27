# SPDX-License-Identifier: Apache-2.0
# Shell tooling extras
{
  lib,
  pkgs,
  vars,
  ...
}:
let
  fdSearchCmd = "${pkgs.fd}/bin/fd --type f --hidden --follow --exclude .git";
in
{
  programs.direnv = lib.mkIf vars.enableExtras {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zoxide = lib.mkIf vars.enableExtras {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.fzf = lib.mkIf vars.enableExtras {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultCommand = fdSearchCmd;
    fileWidgetCommand = fdSearchCmd;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  programs.oh-my-posh = lib.mkIf vars.enableExtras {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    useTheme = "night-owl";
  };
}
