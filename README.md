# NiXOA System

NiXOA system is the **host-specific** flake. It keeps editable site policy in
`config/`, declares the host topology with den, and imports the immutable
`nixoaCore` appliance stack.

## Quick Start

Fresh NixOS VM:

```bash
bash <(curl -fsSL https://codeberg.org/NiXOA/system/raw/branch/beta/scripts/bootstrap.sh) \
  --hostname nixoa \
  --username xoa \
  --ssh-key "$(cat ~/.ssh/id_ed25519.pub)" \
  --first-switch
```

If `curl` or `git` are missing, use:

```bash
nix shell nixpkgs#curl nixpkgs#git -c bash -lc '
  bash <(curl -fsSL https://codeberg.org/NiXOA/system/raw/branch/beta/scripts/bootstrap.sh) \
    --hostname nixoa \
    --username xoa \
    --ssh-key "$(cat ~/.ssh/id_ed25519.pub)" \
    --first-switch
'
```

## Where To Edit

- `config/site.nix`: hostname, timezone, state version, username, SSH keys
- `config/platform.nix`: boot loader and firewall ports
- `config/features.nix`: host feature toggles like `enableExtras`
- `config/packages.nix`: system and user packages
- `config/xo.nix`: XO account, config file, and TLS settings
- `config/storage.nix`: NFS, CIFS, VHD, and mount behavior
- `config/overrides.nix`: optional local overrides applied last

## Dendritic Layout

- `config/compose.nix` merges the editable config fragments into `vars`
- `modules/config/vars.nix` exposes `vars` to the rest of the flake
- `modules/topology/schema.nix` and `modules/topology/hosts.nix` declare den schema and hosts
- `modules/aspects/nixoa-host.nix` defines the stable host aspect
- `modules/aspects/nixoa-user.nix` defines the stable Home Manager user aspect
- `modules/outputs/` contains flake apps and the extras-gated dev shell
- `modules/_nixos/` and `modules/_homeManager/` hold plain implementation modules

## Common Commands

```bash
./scripts/show-diff.sh
./scripts/commit-config.sh "Describe the change"
./scripts/apply-config.sh --hostname nixoa

nix flake check --no-write-lock-file
```

First install without the bootstrap helper:

```bash
./scripts/apply-config.sh --hostname nixoa --first-install
```

## Repository Shape

```text
system/
├── config/
│   ├── compose.nix
│   ├── features.nix
│   ├── overrides.nix.example
│   ├── packages.nix
│   ├── platform.nix
│   ├── site.nix
│   ├── storage.nix
│   └── xo.nix
├── docs/
├── modules/
│   ├── aspects/
│   ├── config/
│   ├── outputs/
│   ├── topology/
│   ├── _homeManager/
│   └── _nixos/
├── scripts/
│   ├── apply-config.sh
│   ├── bootstrap.sh
│   ├── commit-config.sh
│   ├── history.sh
│   ├── lib/common.sh
│   └── show-diff.sh
├── config.nixoa.toml
├── flake.lock
├── flake.nix
└── hardware-configuration.nix
```

## Notes

- `hardware-configuration.nix` is machine-generated and should only be replaced by the bootstrap/manual install flow.
- `nixoaCore` remains the immutable library input. Host-specific policy belongs here in `system/`.
- No `denful` namespace is exported here because the flake is a concrete host configuration, not a reusable aspect library.
