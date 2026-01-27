# SPDX-License-Identifier: Apache-2.0
# System and user packages
{
  pkgs,
  ...
}:
{
  systemPackages = with pkgs; [
    # Add your system packages here
    # Examples:
    #   vim          # text editor
    #   curl         # HTTP client
    #   htop         # system monitor
    #   tmux         # terminal multiplexer
    codex
    claude-code
  ];

  userPackages = with pkgs; [
    # Add your user packages here
    # Examples:
    #   neovim       # modern vim
    #   git          # version control
    #   docker       # containerization
    #   kubectl      # kubernetes CLI
  ];
}
