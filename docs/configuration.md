# Configuration Guide

NiXOA system settings are composed from `configuration.nix` and the files under
`config/`. Edit the files in `config/` to change your host configuration.

## Layout

```
system/
├── configuration.nix          # Aggregates config files
├── config/
│   ├── identity.nix           # hostname, timezone, stateVersion
│   ├── users.nix              # username, sshKeys, xoUser/xoGroup
│   ├── features.nix           # enableXO, enableXenGuest, enableExtras
│   ├── packages.nix           # systemPackages, userPackages
│   ├── networking.nix         # allowedTCPPorts/allowedUDPPorts
│   ├── xo.nix                 # xoConfigFile, TLS options
│   ├── boot.nix               # boot loader selection
│   └── storage.nix            # NFS/CIFS/VHD toggles
└── config.nixoa.toml          # Optional XO overrides
```

## Key Files and Options

### config/identity.nix

```nix
{
  hostname = "nixoa";
  timezone = "UTC";
  stateVersion = "25.11";
}
```

### config/users.nix

```nix
{
  username = "xoa";
  sshKeys = [
    "ssh-ed25519 AAAA... user@host"
  ];

  xoUser = "xo";
  xoGroup = "xo";
}
```

### config/features.nix

```nix
{
  enableXO = true;
  enableXenGuest = true;
  enableExtras = false;
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

### config/networking.nix

```nix
{
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPorts = [ ];
}
```

### config/xo.nix

```nix
{
  xoConfigFile = ../config.nixoa.toml;
  xoHttpHost = "0.0.0.0";

  enableTLS = true;
  enableAutoCert = true;
}
```

### config/boot.nix

```nix
{
  bootLoader = "systemd-boot"; # or "grub"
  efiCanTouchVariables = true;
  grubDevice = "";
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

For additional NixOS settings, add a new module under `modules/features/host/`
(or another feature folder) and register it in `parts/nix/registry/features.nix`.
This keeps changes modular and easy to manage.

## Apply Changes

```bash
./scripts/apply-config.sh "Update configuration"
```

Or preview first:

```bash
./scripts/show-diff.sh
```
