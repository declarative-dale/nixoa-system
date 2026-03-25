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
the bootstrap uses `sudo` for the privileged steps and passes the Xen
Orchestra Cachix URL and signing key explicitly so the initial deployment can
pull cached XO builds without making the repo root-owned. It also stages
`config/overrides.nix` automatically so the generated SSH keys and local
identity settings are included in the flake source immediately.

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

If the repo has local changes, `apply-config.sh` routes through
`commit-config.sh` first. That stages the tracked repo paths, prompts for a
commit message, and auto-generates one from the changed file list when left
blank.

## After Installation

Normal rebuilds become:

```bash
./scripts/apply-config.sh
```
