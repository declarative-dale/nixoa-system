# Configuration Guide

NiXOA system settings are composed from `config/default.nix` and the files under
`config/`. Edit the files in `config/` to change your host configuration.

## Layout

```
system/
├── config/default.nix            # Aggregates config files
├── config/
│   ├── settings.nix           # host identity, user, extras, boot, firewall
│   ├── packages.nix           # systemPackages, userPackages
│   ├── xo.nix                 # XO toggles, service account, config paths, TLS
│   └── storage.nix            # NFS/CIFS/VHD toggles
└── config.nixoa.toml          # Optional XO overrides
```

## Key Files and Options

### config/settings.nix

```nix
{
  hostname = "nixoa";
  timezone = "UTC";
  stateVersion = "25.11";

  username = "xoa";
  sshKeys = [
    "ssh-ed25519 AAAA... user@host"
  ];

  enableExtras = false;

  bootLoader = "systemd-boot"; # or "grub"
  efiCanTouchVariables = true;
  grubDevice = "";

  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPorts = [ ];
}
```

### config/packages.nix

```nix
{ pkgs, ... }:
{
  systemPackages = with pkgs; [
    vim
    htop
  ];

  userPackages = with pkgs; [
    neovim
    git
  ];
}
```

### config/xo.nix

```nix
{
  enableXO = true;
  enableXenGuest = true;

  xoUser = "xo";
  xoGroup = "xo";

  xoConfigFile = ../config.nixoa.toml;
  xoHttpHost = "0.0.0.0";

  enableTLS = true;
  enableAutoCert = true;
}
```

### config/storage.nix

```nix
{
  enableNFS = true;
  enableCIFS = true;
  enableVHD = true;
  mountsDir = "/var/lib/xo/mounts";
  sudoNoPassword = true;
}
```

## Advanced Customizations

For additional NixOS settings, add a new module under `modules/host/`
(or another dendritic module file) and include it from `modules/host.nix` or `modules/user.nix`.
This keeps changes modular and easy to manage.

## Apply Changes

```bash
./scripts/apply-config.sh "Update configuration"
```

Or preview first:

```bash
./scripts/show-diff.sh
```
