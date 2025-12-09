# SPDX-License-Identifier: Apache-2.0
# System configuration for NiXOA CE
# This replaces the old nixoa.toml file with pure Nix

{
  # ============================================================================
  # REQUIRED SETTINGS
  # ============================================================================

  system = "x86_64-linux";
  hostname = "nixoa";
  username = "xoa";
  timezone = "UTC";

  # Add your SSH public keys here (one per line)
  # Example: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host"
  sshKeys = [];

  # ============================================================================
  # XEN ORCHESTRA CONFIGURATION
  # ============================================================================

  xo = {
    host = "0.0.0.0";
    port = 80;
    httpsPort = 443;
  };

  # ============================================================================
  # TLS/SSL CONFIGURATION
  # ============================================================================

  tls = {
    enable = true;
    redirectToHttps = true;
    autoGenerate = true;  # Automatically generate/renew self-signed certs
    dir = "/etc/ssl/xo";
    cert = "/etc/ssl/xo/certificate.pem";
    key = "/etc/ssl/xo/key.pem";
  };

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================

  networking = {
    firewall = {
      allowedTCPPorts = [80 443 3389 5900 8012];
    };
  };

  # ============================================================================
  # STORAGE & MOUNTING
  # ============================================================================

  storage = {
    nfs.enable = true;
    cifs.enable = true;
    mountsDir = "/var/lib/xo/mounts";
  };

  # ============================================================================
  # TERMINAL ENHANCEMENTS
  # ============================================================================

  extras = {
    enable = false;
  };

  # ============================================================================
  # AUTOMATED UPDATES
  # ============================================================================

  updates = {
    repoDir = "/etc/nixos/nixoa-ce";
    protectPaths = ["hardware-configuration.nix"];

    monitoring = {
      notifyOnSuccess = false;

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
        url = "";
      };
    };

    gc = {
      enable = false;
      schedule = "Sun 04:00";
      keepGenerations = 7;
    };

    flake = {
      enable = false;
      schedule = "Sun 04:00";
      remoteUrl = "https://codeberg.org/dalemorgan/nixoa-ce.git";
      branch = "main";
      autoRebuild = false;
    };

    nixpkgs = {
      enable = false;
      schedule = "Mon 04:00";
      keepGenerations = 7;
    };

    xoa = {
      enable = false;
      schedule = "Tue 04:00";
      keepGenerations = 7;
    };

    libvhdi = {
      enable = false;
      schedule = "Wed 04:00";
      keepGenerations = 7;
    };
  };

  # ============================================================================
  # SERVICE ACCOUNT SETTINGS
  # ============================================================================

  service = {
    xoUser = "xo";
    xoGroup = "xo";
  };

  # ============================================================================
  # CUSTOM PACKAGES
  # ============================================================================

  packages = {
    system.extra = [];
    user.extra = [];
  };

  # ============================================================================
  # CUSTOM SERVICES
  # ============================================================================

  # Enable common NixOS services by name (uses default configurations)
  services = {
    enable = [];
    # Example: enable = ["docker" "tailscale" "fail2ban"];
  };

  # Configure services with custom options (uncomment and customize as needed):
  # services.docker = {
  #   enable = true;
  #   enableOnBoot = true;
  #   autoPrune = {
  #     enable = true;
  #     dates = "weekly";
  #   };
  # };

  # ============================================================================
  # NIXOS STATE VERSION
  # ============================================================================

  stateVersion = "25.11";
}
