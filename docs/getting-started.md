# Getting Started

## Fastest Path

On a fresh NixOS VM, run:

```bash
bash <(curl -fsSL https://codeberg.org/NiXOA/system/raw/branch/beta/scripts/bootstrap.sh) \
  --hostname nixoa \
  --username xoa \
  --ssh-key "$(cat ~/.ssh/id_ed25519.pub)" \
  --first-switch
```

The bootstrap script will:

- clone or update the `system` repo on the `beta` branch
- copy `hardware-configuration.nix`
- optionally write `config/overrides.nix`
- run `nix flake check --no-write-lock-file`
- optionally run the first switch with Determinate’s install cache override

## Manual Path

```bash
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
./scripts/apply-config.sh --hostname nixoa --first-install
```

After that, normal rebuilds can omit `--first-install`.
