# SPDX-License-Identifier: Apache-2.0
# Xen Guest Agent configuration for better VM integration

{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nixoa.xen-guest;
in
{
  options.nixoa.xen-guest = {
    enable = mkEnableOption "Xen guest agent for better VM integration" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Xen guest agent for better VM integration
    systemd.packages = [ pkgs.xen-guest-agent ];
    systemd.services.xen-guest-agent.wantedBy = [ "multi-user.target" ];
  };
}
