# SPDX-License-Identifier: Apache-2.0
# Bash configuration
{ ... }:
{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    profileExtra = ''
      if [[ $- == *i* ]] && [[ -n "''${SSH_TTY:-}" ]] && [[ -t 0 ]] && [[ -t 1 ]] && [[ -z "''${NIXOA_TUI_BYPASS:-}" ]] && [[ -z "''${NIXOA_TUI_ACTIVE:-}" ]]; then
        export NIXOA_TUI_ACTIVE=1
        exec nixoa-menu
      fi
    '';
  };
}
