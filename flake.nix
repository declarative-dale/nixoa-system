# SPDX-License-Identifier: Apache-2.0
# User configuration flake for NixOA - Entry point for system configuration

{
  description = "User configuration flake for NixOA - Entry point for system config";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    core = {
      url = "git+https://codeberg.org/NiXOA/core?ref=beta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.follows = "core/home-manager";
    snitch.url = "github:karol-broda/snitch";
  };
  nixConfig = {
    extra-substituters = [
      "https://xen-orchestra-ce.cachix.org"
    ];
    extra-trusted-public-keys = [
      "xen-orchestra-ce.cachix.org-1:WAOajkFLXWTaFiwMbLidlGa5kWB7Icu29eJnYbeMG7E="
    ];
  };
  outputs =
    inputs:
    let
      # =====================================================================
      # SYSTEM CONFIGURATION VARIABLES
      # Single source of truth for all system settings
      # =====================================================================
      vars = {
        # System identification
        hostname = "nixoa";
        timezone = "UTC";
        stateVersion = "25.11";

        # Admin user configuration
        username = "xoa";
        sshKeys = [ ]; # Add your SSH public keys here

        # XO service account
        xoUser = "xo";
        xoGroup = "xo";

        # Feature toggles
        enableExtras = false; # Enhanced terminal tools with zsh shell (bash used when disabled)
        enableXenGuest = true; # Xen guest agent
        enableXO = true; # Xen Orchestra service

        # XO configuration
        xoConfigFile = ./config.nixoa.toml;
        xoHttpHost = "0.0.0.0";
        xoHttpPort = 80;
        xoHttpsPort = 443;

        # TLS/HTTPS configuration
        enableTLS = true;
        redirectToHttps = true;
        enableAutoCert = true; # Automatic self-signed certificate generation

        # Storage backends
        enableNFS = true;
        enableCIFS = true;
        enableVHD = true;
        mountsDir = "/var/lib/xo/mounts";
        sudoNoPassword = true;

        # Boot configuration
        bootLoader = "systemd-boot"; # Options: "systemd-boot" or "grub"
        efiCanTouchVariables = true;
        grubDevice = ""; # Set to device path if using GRUB

        # Firewall
        allowedTCPPorts = [
          80
          443
        ];

        # Updates configuration
        updatesRepoDir = "~/projects/NiXOA/system";
        updatesMonitoringNotifyOnSuccess = false;
        updatesMonitoringEmailEnable = false;
        updatesMonitoringEmailTo = "admin@example.com";
        updatesMonitoringNtfyEnable = false;
        updatesMonitoringNtfyServer = "https://ntfy.sh";
        updatesMonitoringNtfyTopic = "xoa-updates";
        updatesMonitoringWebhookEnable = false;
        updatesMonitoringWebhookUrl = "";
        updatesAutoUpgradeEnable = false;
        updatesAutoUpgradeSchedule = "Sun 04:00";
        updatesAutoUpgradeFlake = "";
        updatesNixpkgsEnable = false;
        updatesNixpkgsSchedule = "Mon 04:00";
        updatesXoaEnable = false;
        updatesXoaSchedule = "Tue 04:00";
        updatesLibvhdiEnable = false;
        updatesLibvhdiSchedule = "Wed 04:00";
      };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./flake ];

      # Make vars available to all flake outputs
      _module.args = { inherit vars; };
    };
}
