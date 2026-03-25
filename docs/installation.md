# Installation

NiXOA system is designed to be installed directly on the target NixOS host.
`core` is consumed as a flake input; you do not install it separately.

## Recommended One-Liner

```bash
bash <(curl -fsSL https://codeberg.org/NiXOA/system/raw/branch/beta/scripts/bootstrap.sh) --first-switch
```

The bootstrap script prompts for hostname, username, time zone, and at least
one SSH public key.

## Manual Install

1. Clone the repository.

```bash
git clone --branch beta https://codeberg.org/NiXOA/system.git ~/system
cd ~/system
```

2. Copy the generated hardware profile.

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

3. Edit the `config/` files or create `config/overrides.nix`.

4. Validate the flake.

```bash
nix flake check --no-write-lock-file
```

5. Run the first switch with Determinate’s install cache override.

```bash
./scripts/apply-config.sh --first-install
```

## After Installation

Normal rebuilds become:

```bash
./scripts/apply-config.sh
```
