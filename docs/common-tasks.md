# Common Tasks

## Add SSH Keys

Edit `config/site.nix` or `config/overrides.nix`:

```nix
{
  sshKeys = [ "ssh-ed25519 AAAA... user@host" ];
}
```

## Open Firewall Ports

Edit `config/platform.nix`:

```nix
{
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPorts = [ 53 ];
}
```

## Enable Extras

Edit `config/features.nix`:

```nix
{ enableExtras = true; }
```

## Add Packages

Edit `config/packages.nix`:

```nix
{ pkgs, ... }:
{
  systemPackages = with pkgs; [ htop ];
  userPackages = with pkgs; [ git ];
}
```

## Toggle Storage Backends

Edit `config/storage.nix`:

```nix
{
  enableNFS = true;
  enableCIFS = true;
  enableVHD = true;
}
```

## Switch Boot Loader

Edit `config/platform.nix`:

```nix
{ bootLoader = "grub"; }
```

## Apply

```bash
./scripts/apply-config.sh --hostname nixoa
```
