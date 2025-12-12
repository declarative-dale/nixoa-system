# SPDX-License-Identifier: Apache-2.0
# NixOA Configuration Module
# ==============================================================================
# Converts system-settings.toml into NixOS module configuration.
# This provides a convenient TOML frontend for the nixoa.* options defined
# in nixoa-vm/modules/nixoa-options.nix.
# ==============================================================================

{ lib, ... }:

let
  # Read and parse TOML with error handling
  settingsPath = ../system-settings.toml;
  settings =
    if !builtins.pathExists settingsPath then
      builtins.throw ''
        user-config: system-settings.toml is missing!

        Please copy the sample configuration:
          cp system-settings.toml.sample system-settings.toml

        Then customize it for your deployment.
      ''
    else
      builtins.fromTOML (builtins.readFile settingsPath);

  # Import XO server config generator (returns filtered TOML text)
  xoServerConfigText = import ./xo-server-config.nix {};

  # Helper to get value with fallback
  get = path: default:
    let
      getValue = config: pathList:
        if pathList == []
        then config
        else if builtins.isAttrs config && builtins.hasAttr (builtins.head pathList) config
        then getValue config.${builtins.head pathList} (builtins.tail pathList)
        else null;
      result = getValue settings path;
    in
      if result == null then default else result;

  # Filter comment/example SSH keys
  # Removes any keys starting with "_comment" or "_example"
  cleanSshKeys = keys:
    builtins.filter (key:
      !(builtins.isString key &&
        (builtins.substring 0 8 key == "_comment" ||
         builtins.substring 0 8 key == "_example"))
    ) keys;
in
{
  # ==========================================================================
  # Set all nixoa.* configuration values from TOML
  # ==========================================================================

  # NOTE: 'system' is NOT set here - that's determined by nixoa-vm/flake.nix
  # Modules cannot override the flake-level system architecture

  config.nixoa = {
    # System identification
    hostname = get ["hostname"] "nixoa";
    stateVersion = get ["stateVersion"] "25.11";

    # Admin user
    admin = {
      username = get ["username"] "xoa";
      sshKeys = cleanSshKeys (get ["sshKeys"] []);
    };

    # Xen Orchestra configuration
    xo = {
      host = get ["xo" "host"] "0.0.0.0";
      port = get ["xo" "port"] 80;
      httpsPort = get ["xo" "httpsPort"] 443;

      service = {
        user = get ["service" "xoUser"] "xo";
        group = get ["service" "xoGroup"] "xo";
      };

      tls = {
        enable = get ["tls" "enable"] true;
        redirectToHttps = get ["tls" "redirectToHttps"] true;
        autoGenerate = get ["tls" "autoGenerate"] true;
        dir = get ["tls" "dir"] "/etc/ssl/xo";
        cert = get ["tls" "cert"] "/etc/ssl/xo/certificate.pem";
        key = get ["tls" "key"] "/etc/ssl/xo/key.pem";
      };
    };

    # Storage
    storage = {
      nfs.enable = get ["storage" "nfs" "enable"] true;
      cifs.enable = get ["storage" "cifs" "enable"] true;
      vhd.enable = true;  # Always enabled for VHD support
      mountsDir = get ["storage" "mountsDir"] "/var/lib/xo/mounts";
    };

    # Networking
    networking.firewall.allowedTCPPorts = get ["networking" "firewall" "allowedTCPPorts"] [80 443 3389 5900 8012];

    # Timezone
    timezone = get ["timezone"] "UTC";

    # Packages
    packages = {
      system.extra = get ["packages" "system" "extra"] [];
      user.extra = get ["packages" "user" "extra"] [];
    };

    # Terminal extras
    extras.enable = get ["extras" "enable"] false;

    # Updates configuration
    updates = {
      repoDir = get ["updates" "repoDir"] "/etc/nixos/nixoa/nixoa-vm";
      protectPaths = get ["updates" "protectPaths"] ["hardware-configuration.nix"];

      monitoring = {
        notifyOnSuccess = get ["updates" "monitoring" "notifyOnSuccess"] false;

        email = {
          enable = get ["updates" "monitoring" "email" "enable"] false;
          to = get ["updates" "monitoring" "email" "to"] "admin@example.com";
        };

        ntfy = {
          enable = get ["updates" "monitoring" "ntfy" "enable"] false;
          server = get ["updates" "monitoring" "ntfy" "server"] "https://ntfy.sh";
          topic = get ["updates" "monitoring" "ntfy" "topic"] "xoa-updates";
        };

        webhook = {
          enable = get ["updates" "monitoring" "webhook" "enable"] false;
          url = get ["updates" "monitoring" "webhook" "url"] "";
        };
      };

      gc = {
        enable = get ["updates" "gc" "enable"] false;
        schedule = get ["updates" "gc" "schedule"] "Sun 04:00";
        keepGenerations = get ["updates" "gc" "keepGenerations"] 7;
      };

      flake = {
        enable = get ["updates" "flake" "enable"] false;
        schedule = get ["updates" "flake" "schedule"] "Sun 04:00";
        remoteUrl = get ["updates" "flake" "remoteUrl"] "https://codeberg.org/nixoa/nixoa-vm.git";
        branch = get ["updates" "flake" "branch"] "main";
        autoRebuild = get ["updates" "flake" "autoRebuild"] false;
      };

      nixpkgs = {
        enable = get ["updates" "nixpkgs" "enable"] false;
        schedule = get ["updates" "nixpkgs" "schedule"] "Mon 04:00";
        keepGenerations = get ["updates" "nixpkgs" "keepGenerations"] 7;
      };

      xoa = {
        enable = get ["updates" "xoa" "enable"] false;
        schedule = get ["updates" "xoa" "schedule"] "Tue 04:00";
        keepGenerations = get ["updates" "xoa" "keepGenerations"] 7;
      };

      libvhdi = {
        enable = get ["updates" "libvhdi" "enable"] false;
        schedule = get ["updates" "libvhdi" "schedule"] "Wed 04:00";
        keepGenerations = get ["updates" "libvhdi" "keepGenerations"] 7;
      };
    };

    # ==========================================================================
    # Custom services: parse [services] section from TOML
    # ==========================================================================

    services.definitions =
      let
        # Get services section, excluding 'enable' list
        rawServicesConfig = if builtins.hasAttr "services" settings
                            then builtins.removeAttrs settings.services ["enable"]
                            else {};

        # Filter valid service names (lowercase alphanumeric with dashes/underscores)
        # This prevents non-service attributes from being treated as services
        servicesConfig = builtins.listToAttrs (
          builtins.filter
            (item: item != null)
            (map
              (name:
                if (builtins.match "^[a-z][a-z0-9_-]*$" name) != null
                then { inherit name; value = rawServicesConfig.${name}; }
                else null
              )
              (builtins.attrNames rawServicesConfig)
            )
        );

        # Get simple enable list: services.enable = ["docker", "tailscale"]
        enableList = get ["services" "enable"] [];

        # Convert enable list to { serviceName = { enable = true; }; }
        enabledServices = builtins.listToAttrs (
          map (serviceName: {
            name = serviceName;
            value = { enable = true; };
          }) enableList
        );
      in
        # Merge: detailed configs take precedence over simple enable list
        enabledServices // servicesConfig;
  };

  # ==========================================================================
  # Place XO server override configuration file
  # ==========================================================================

  environment.etc."xo-server/config.nixoa.toml" = {
    text = xoServerConfigText;
    mode = "0644";
  };
}
