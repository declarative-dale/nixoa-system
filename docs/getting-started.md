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

**Note** make sure you have already enabled a 4GB swap file using the NixOS installer, if you didn't, add this to your `hardware-configuration.nix` BEFORE copying it over.

```bash
swapDevices = [
             {
               device = "/swapfile";
               size = 4096;  # in MB (4GB)
             }
         ];
```

Now, copy the config over
```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

## 3) Edit settings

Update the files under `config/`:

- `config/settings.nix` (hostname, timezone, stateVersion, username, sshKeys, enableExtras, boot, firewall)
- `config/xo.nix` (enableXO, enableXenGuest, xoUser/xoGroup)
- `config/packages.nix` (systemPackages, userPackages)

## 4) Build/apply

```bash
./scripts/apply-config.sh "Initial NiXOA setup"
```

### First Rebuild (Determinate Cache)

On a fresh host, run the first switch with Determinate's install cache:

```bash
sudo nixos-rebuild switch --flake .#HOSTNAME \
  --option extra-substituters https://install.determinate.systems \
  --option extra-trusted-public-keys cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=
```

## 5) Verify

```bash
systemctl status xo-server
```

## Notes

- `modules/user-configuration.nix` is an aggregator; edit the files in `config/` instead.
- Core is pulled as a flake input; you do not need to clone it locally.
