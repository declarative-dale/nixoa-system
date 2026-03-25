# Installation

NiXOA system is designed to be installed directly on the target NixOS host.
`core` is consumed as a flake input; you do not install it separately.

## Recommended One-Liner

```bash
bash <(curl -fsSL https://codeberg.org/NiXOA/system/raw/branch/beta/scripts/bootstrap.sh) \
  --enable-flakes \
  --first-switch
```

The bootstrap script prompts for hostname, username, time zone, and at least
one SSH public key. `--enable-flakes` persists `nix-command flakes` first so
the install works on a fresh NixOS VM. Before the first validation or switch,
the bootstrap also seeds `/etc/nix/nix.conf` with the Xen Orchestra Cachix URL
and signing key so the initial deployment can pull cached XO builds. If you
are not root, expect a `sudo` prompt for that step.

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
export NIX_CONFIG="experimental-features = nix-command flakes"
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
