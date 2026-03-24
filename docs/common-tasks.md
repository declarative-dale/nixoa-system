# Common Tasks

Quick edits for typical NiXOA changes. Most settings live under `config/`.

## Add system packages

Edit `config/packages.nix`:

```nix
{ pkgs, ... }:
{
  systemPackages = with pkgs; [
    vim
    htop
  ];
}
```

## Add user packages

Edit `config/packages.nix`:

```nix
{ pkgs, ... }:
{
  userPackages = with pkgs; [
    neovim
    git
  ];
}
```

## Add SSH keys

Edit `config/settings.nix`:

```nix
{
  sshKeys = [
    "ssh-ed25519 AAAA... user@host"
  ];
}
```

## Open firewall ports

Edit `config/settings.nix`:

```nix
{
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPorts = [ 53 ];
}
```

## Enable extras (zsh + tooling)

Edit `config/settings.nix`:

```nix
{ enableExtras = true; }
```

## Enable storage backends

Edit `config/storage.nix`:

```nix
{
  enableNFS = true;
  enableCIFS = true;
  enableVHD = true;
}
```

## Switch boot loader

Edit `config/settings.nix`:

```nix
{ bootLoader = "grub"; }
```

## Apply changes

```bash
./scripts/apply-config.sh "Update settings"
```

## Advanced: extra NixOS options

Add a new module under `modules/host/` and register it in
the dendritic `modules/host.nix` or `modules/user.nix` files for clean, reusable overrides.
