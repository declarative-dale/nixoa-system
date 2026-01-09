# SPDX-License-Identifier: Apache-2.0
# ============================================================================
# NiXOA Settings - Centralized Configuration
# ============================================================================
# This file contains all user-configurable settings for your NiXOA system.
# Edit values here and run `sudo nixos-rebuild switch` to apply changes.
# ============================================================================

{ pkgs, lib, ... }:

{
  # ==========================================================================
  # SYSTEM IDENTIFICATION
  # ==========================================================================

  hostname = "nixoa";
  timezone = "UTC";
  stateVersion = "25.11"; # Don't change this after initial installation

  # ==========================================================================
  # USER ACCOUNTS
  # ==========================================================================

  # Admin user configuration
  username = "xoa";
  sshKeys = [
    # Add your SSH public keys here, one per line
    # Example: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG... user@hostname"
  ];

  # XO service account (usually no need to change)
  xoUser = "xo";
  xoGroup = "xo";

  # ==========================================================================
  # FEATURE TOGGLES
  # ==========================================================================

  enableExtras = false; # Enhanced terminal tools with zsh shell (bash used when disabled)
  enableXenGuest = true; # Xen guest agent for better VM integration
  enableXO = true; # Xen Orchestra service

  # ==========================================================================
  # SYSTEM PACKAGES
  # ==========================================================================
  # Add system-level packages that should be available to all users
  # These are installed at the system level via environment.systemPackages

  systemPackages = with pkgs; [
    # Add your system packages here
    # Examples:
    #   vim          # text editor
    #   curl         # HTTP client
    #   htop         # system monitor
    #   tmux         # terminal multiplexer
  ];

  # ==========================================================================
  # USER PACKAGES
  # ==========================================================================
  # Add user-level packages for the admin user
  # These are installed via home-manager and only available to the admin user

  userPackages = with pkgs; [
    # Add your user packages here
    # Examples:
    #   neovim       # modern vim
    #   git          # version control
    #   docker       # containerization
    #   kubectl      # kubernetes CLI
  ];

  # ==========================================================================
  # NETWORKING & FIREWALL
  # ==========================================================================

  allowedTCPPorts = [
    80 # HTTP
    443 # HTTPS
    # Add additional ports here as needed
  ];

  # ==========================================================================
  # XEN ORCHESTRA CONFIGURATION
  # ==========================================================================

  xoConfigFile = ./config.nixoa.toml;
  xoHttpHost = "0.0.0.0"; # Used in TLS certificate generation (Subject Alternative Name)

  # TLS/HTTPS configuration
  enableTLS = true;
  enableAutoCert = true; # Automatic self-signed certificate generation

  # ==========================================================================
  # BOOT CONFIGURATION
  # ==========================================================================

  bootLoader = "systemd-boot"; # Options: "systemd-boot" or "grub"
  efiCanTouchVariables = true;
  grubDevice = ""; # Set to device path (e.g., "/dev/sda") if using GRUB

  # ==========================================================================
  # STORAGE BACKENDS
  # ==========================================================================

  enableNFS = true; # Enable NFS storage backend support
  enableCIFS = true; # Enable CIFS/SMB storage backend support
  enableVHD = true; # Enable VHD file support
  mountsDir = "/var/lib/xo/mounts";
  sudoNoPassword = true; # Allow xo user to mount without password
}
