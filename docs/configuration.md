# Configuration Guide

NiXOA system composes host policy from `config/*.nix` into a single `vars`
attribute set. Edit the files in `config/`; the modules under `modules/` wire
that data into den, NixOS, and Home Manager.

## Layout

```text
config/
├── compose.nix            # merges the config fragments into `vars`
├── site.nix               # hostname, timezone, username, SSH keys
├── platform.nix           # boot loader and firewall defaults
├── features.nix           # host feature toggles
├── packages.nix           # systemPackages and userPackages
├── xo.nix                 # XO service account and TLS/runtime settings
├── storage.nix            # NFS/CIFS/VHD behavior
└── overrides.nix          # optional host-local overrides, imported last
```

## Key Files

### `config/site.nix`

```nix
{
  hostname = "nixoa";
  timezone = "UTC";
  stateVersion = "25.11";
  username = "xoa";
  sshKeys = [ "ssh-ed25519 AAAA... user@host" ];
}
```

### `config/platform.nix`

```nix
{
  bootLoader = "systemd-boot";
  efiCanTouchVariables = true;
  grubDevice = "";
  allowedTCPPorts = [ 80 443 ];
  allowedUDPPorts = [ ];
}
```

### `config/features.nix`

```nix
{
  enableExtras = false;
  enableXO = true;
  enableXenGuest = true;
}
```

### `config/packages.nix`

```nix
{ pkgs, ... }:
{
  systemPackages = with pkgs; [ vim htop ];
  userPackages = with pkgs; [ git neovim ];
}
```

### `config/xo.nix`

```nix
{
  xoUser = "xo";
  xoGroup = "xo";
  xoConfigFile = ../config.nixoa.toml;
  xoHttpHost = "0.0.0.0";
  enableTLS = true;
  enableAutoCert = true;
}
```

## Topology And Aspect Wiring

- `modules/config/vars.nix` imports `config/compose.nix`
- `modules/topology/schema.nix` sets den defaults shared across users
- `modules/topology/hosts.nix` declares the concrete host and user from `vars`
- `modules/aspects/nixoa-host.nix` imports the plain NixOS implementation modules
- `modules/aspects/nixoa-user.nix` imports the Home Manager profile

## Advanced Customization

For extra NixOS behavior, add a module under `modules/_nixos/` and import it
from [nixoa-host.nix](/home/nixos/projects/NiXOA/system/modules/aspects/nixoa-host.nix).

For extra Home Manager behavior, add a file under
[modules/_homeManager/profile/features](/home/nixos/projects/NiXOA/system/modules/_homeManager/profile/features).
Directory imports will pull it in automatically.
