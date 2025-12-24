{ lib, pkgs, ... }:

{
  # ============================================================================
  # USER SETTINGS (passed to Home Manager modules)
  # ============================================================================
  userSettings = {
    # User-specific packages
    packages.extra = [];  # Example: [ "neovim" "tmux" "lazygit" ]

    # Terminal extras (zsh enhancements, etc.)
    extras.enable = false;
  };

  # ============================================================================
  # SYSTEM SETTINGS (passed to NixOS modules)
  # ============================================================================
  systemSettings = {
    # System identification
    hostname = "nixoa";
    timezone = "UTC";
    stateVersion = "25.11";

    # Admin user
    username = "xoa";
    sshKeys = [];  # Example: [ "ssh-ed25519 AAAA..." ]

    # Networking - firewall configuration
    networking.firewall.allowedTCPPorts = [ 80 443 3389 5900 8012 ];

    # XO Server configuration
    xo = {
      host = "0.0.0.0";
      port = 80;
      httpsPort = 443;

      service = {
        user = "xo";
        group = "xo";
      };

      tls = {
        enable = true;
        redirectToHttps = true;
        autoGenerate = true;
        dir = "/etc/ssl/xo";
        cert = "/etc/ssl/xo/certificate.pem";
        key = "/etc/ssl/xo/key.pem";
      };
    };

    # Storage configuration
    storage = {
      nfs.enable = true;
      cifs.enable = true;
      vhd.enable = true;
      mountsDir = "/var/lib/xo/mounts";
    };

    # System-wide packages
    packages.system.extra = [];  # Example: [ "vim" "git" "htop" ]

    # Automated updates configuration
    updates = {
      repoDir = "/etc/nixos/nixoa/nixoa-vm";

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
        schedule = "monthly";  # Default: monthly. Also supports: "weekly", "daily", "*-*-01 04:00", etc.
      };

      autoUpgrade = {
        enable = false;
        schedule = "Sun 04:00";
        flake = "";  # Set to your flake URI, e.g., "github:yourusername/user-config"
      };

      nixpkgs = {
        enable = false;
        schedule = "Mon 04:00";
      };

      xoa = {
        enable = false;
        schedule = "Tue 04:00";
      };

      libvhdi = {
        enable = false;
        schedule = "Wed 04:00";
      };
    };

    # Custom services - map of service name to configuration
    services.definitions = {};
    # Example:
    # services.definitions = {
    #   docker = { enable = true; enableOnBoot = true; };
    #   tailscale = { enable = true; };
    # };
  };
}
