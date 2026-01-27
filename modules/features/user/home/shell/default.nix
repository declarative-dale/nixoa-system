# SPDX-License-Identifier: Apache-2.0
# Shell configuration bundle
{ ... }:
{
  imports = [
    ./bash.nix
    ./zsh.nix
    ./extras.nix
  ];
}
