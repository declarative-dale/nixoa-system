# SPDX-License-Identifier: Apache-2.0
# Home Manager feature set
{ ... }:
{
  imports = [
    ./home/base.nix
    ./home/packages.nix
    ./home/session.nix
    ./home/tools.nix
    ./home/shell
  ];
}
