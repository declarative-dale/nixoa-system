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
├── xo.nix                 # XO runtime and TLS settings
├── storage.nix            # NFS/CIFS/VHD behavior
└── overrides.nix          # optional host-local overrides, imported last
```

## Key Files

### `config/site.nix`

```nix
{
  hostSystem = "x86_64-linux";
  hostname = "nixoa";
  timezone = "Europe/Paris";
  stateVersion = "25.11";
  username = "nixoa";
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
  xoConfigFile = ../config.nixoa.toml;
  xoHttpHost = "0.0.0.0";
  enableTLS = true;
  enableAutoCert = true;
}
```

## Topology And Aspect Wiring

- `modules/config/values.nix` imports `config/compose.nix`
- `modules/topology/classes.nix` sets den defaults shared across users
- `modules/topology/hosts.nix` declares the concrete host and user from `vars`
- `modules/aspects/defaults.nix` wires den-wide defaults like hostname and HM state
- `modules/aspects/host.nix` extends the concrete host aspect
- `modules/aspects/user.nix` extends the concrete user aspect

## Advanced Customization

For extra NixOS behavior, add a module under `modules/nixos/` and import it
from [host.nix](/home/nixos/projects/NiXOA/system/modules/aspects/host.nix).

For extra Home Manager behavior, add a file under
[modules/home](/home/nixos/projects/NiXOA/system/modules/home). Import it from
[default.nix](/home/nixos/projects/NiXOA/system/modules/home/default.nix) if it
belongs in the default profile.
