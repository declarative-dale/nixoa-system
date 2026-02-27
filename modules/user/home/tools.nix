# SPDX-License-Identifier: Apache-2.0
# Extra tooling configuration
{
  lib,
  pkgs,
  vars,
  ...
}:
{
  programs.bat = lib.mkIf vars.enableExtras {
    enable = true;
    config = {
      theme = "Dracula";
      style = "changes,header";
      map-syntax = [
        "*.conf:INI"
        ".ignore:Git Ignore"
      ];
    };
  };

  programs.git = lib.mkIf vars.enableExtras {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.pager = "${pkgs.delta}/bin/delta";
      delta = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
