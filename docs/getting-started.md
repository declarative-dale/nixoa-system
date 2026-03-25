# Getting Started

## Fastest Path

On a fresh NixOS VM, run:

```bash
bash <(curl -fsSL https://codeberg.org/NiXOA/system/raw/branch/beta/scripts/bootstrap.sh) \
  --enable-flakes \
  --first-switch
```

The bootstrap script will:

- clone or update the `system` repo on the `beta` branch
- persist `nix-command flakes` when `--enable-flakes` is used
- run the initial validation with `sudo` and explicit Xen Orchestra Cachix options
- copy `hardware-configuration.nix`
- prompt for hostname, username, time zone, and an SSH public key
- write `config/overrides.nix`
- run `nix flake check --no-write-lock-file`
- optionally run the first switch with Determinate’s install cache override

## Manual Path

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
git clone --branch beta https://codeberg.org/NiXOA/system.git ~/system
cd ~/system
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
cp config/overrides.nix.example config/overrides.nix
```

Then edit:

- `config/site.nix`
- `config/platform.nix`
- `config/features.nix`
- `config/packages.nix`
- `config/xo.nix`
- `config/storage.nix`
- optionally `config/overrides.nix`

Apply the first switch:

```bash
./scripts/apply-config.sh --first-install
```

After that, normal rebuilds can omit `--first-install`.
