# SPDX-License-Identifier: Apache-2.0
# NixOA User Configuration - Direct option assignments
# This file defines the system configuration using the config.nixoa.* option namespace

{ config, lib, pkgs, ... }:
{
  # ============================================================================
  # SYSTEM IDENTIFICATION & LOCALE
  # ============================================================================

  nixoa.system = {
    hostname = "nixoa";
    timezone = "UTC";
    stateVersion = "25.11";
  };

  # ============================================================================
  # BOOT & BOOTLOADER
  # ============================================================================

  nixoa.boot = {
    # Boot loader selection: "systemd-boot" (default, recommended for EFI) or "grub" (for BIOS/legacy)
    loader = "systemd-boot";

    # EFI configuration (only used with systemd-boot)
    efi.canTouchEfiVariables = true;

    # GRUB configuration (only used when loader = "grub")
    # Uncomment and set to device path to use GRUB instead of systemd-boot
    # grub.device = "/dev/sda";  # Examples: /dev/sda, /dev/vda (Xen), /dev/xvda
  };

  # To switch to GRUB for legacy/BIOS boot, uncomment and modify the boot section:
  # nixoa.boot = {
  #   loader = "grub";
  #   grub.device = "/dev/sda";  # Set to your boot device
  # };

  # ============================================================================
  # ADMIN USER & XO SERVICE ACCOUNT
  # ============================================================================

  nixoa.admin = {
    username = "xoa";
    sshKeys = [];  # Example: [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExample user@example.com" ]
    shell = "bash";  # Options: "bash" or "zsh", selecting zsh will trigger numerous terminal enhancements
  };

  nixoa.xo.service = {
    user = "xo";
    group = "xo";
  };

  # ============================================================================
  # XO SERVER CONFIGURATION
  # ============================================================================

  nixoa.xo = {
    enable = true;

    configNixoaFile = ./config.nixoa.toml;

    http = {
      host = "0.0.0.0";
      port = 80;
      httpsPort = 443;
    };

    tls = {
      enable = true;
      redirectToHttps = true;
      autoGenerate = true;
    };
  };

  # ============================================================================
  # STORAGE CONFIGURATION
  # ============================================================================

  nixoa.storage = {
    nfs.enable = true;
    cifs.enable = true;
    vhd.enable = true;
  };

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # ============================================================================
  # PACKAGE MANAGEMENT
  # ============================================================================

  environment.systemPackages = with pkgs; [
    # Add system-wide packages here
    # Example: vim git curl htop
  ];

  # ============================================================================
  # AUTOMATED UPDATES & MAINTENANCE
  # ============================================================================

  updates = {
    repoDir = "~/user-config";  # Path to user-config flake (~ expands to admin user home)

    # ========================================================================
    # UPDATE MONITORING & NOTIFICATIONS
    # ========================================================================
    monitoring = {
      notifyOnSuccess = false;  # Send notifications for successful updates

      email = {
        enable = false;
        to = "admin@example.com";
      };

      ntfy = {
        enable = false;
        server = "https://ntfy.sh";
        topic = "xoa-updates";
      };

      webhook = {
        enable = false;
        url = "";  # Example: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
      };
    };

    # ========================================================================
    # SYSTEM AUTO-UPGRADE
    # ========================================================================
    autoUpgrade = {
      enable = false;
      schedule = "Sun 04:00";
      flake = "";  # Example: "github:yourusername/user-config"
    };

    # ========================================================================
    # NIXPKGS INPUT UPDATES
    # ========================================================================
    nixpkgs = {
      enable = false;
      schedule = "Mon 04:00";
    };

    # ========================================================================
    # XEN ORCHESTRA UPSTREAM UPDATES
    # ========================================================================
    xoa = {
      enable = false;
      schedule = "Tue 04:00";
    };

    # ========================================================================
    # LIBVHDI SOURCE UPDATES
    # ========================================================================
    libvhdi = {
      enable = false;
      schedule = "Wed 04:00";
    };
  };
}
