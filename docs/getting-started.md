# Getting Started

This repo is the host-specific NiXOA configuration. It pulls in `core` as a
flake input and defines your machine in `config/`.

## 1) Clone the repo

```bash
git clone https://codeberg.org/NiXOA/system.git ~/system
cd ~/system
```

## 2) Add your hardware config

Copy your generated hardware config into this repo (do not edit it):

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

## 3) Edit settings

Update the files under `config/`:

- `config/identity.nix` (hostname, timezone, stateVersion)
- `config/users.nix` (username, sshKeys)
- `config/features.nix` (enableXO, enableExtras)
- `config/packages.nix` (systemPackages, userPackages)

## 4) Build/apply

```bash
./scripts/apply-config.sh "Initial NiXOA setup"
```

## 5) Verify

```bash
systemctl status xo-server
```

## Notes

- `configuration.nix` is an aggregator; edit the files in `config/` instead.
- Core is pulled as a flake input; you do not need to clone it locally.
