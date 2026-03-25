# NiXOA System

NiXOA system is the **host-specific** flake. It keeps editable site policy in
`config/`, declares the host topology with den, and imports the immutable
`nixoaCore` appliance stack.

Current release series: `v3.1.0`

## Quick Start

Fresh NixOS VM:

```bash
bash <(curl -fsSL https://codeberg.org/NiXOA/system/raw/branch/beta/scripts/bootstrap.sh) --first-switch
```

The bootstrap flow prompts for:
- hostname, default `nixoa`
- username, default `nixoa`
- time zone, default `Europe/Paris`
- at least one SSH public key, required

If `curl` or `git` are missing, use:

```bash
nix shell nixpkgs#curl nixpkgs#git -c bash -lc '
  bash <(curl -fsSL https://codeberg.org/NiXOA/system/raw/branch/beta/scripts/bootstrap.sh) \
    --first-switch
'
```

## Edit Surface

- `config/site.nix`: system, hostname, timezone, state version, username, SSH keys
- `config/platform.nix`: boot loader and firewall ports
- `config/features.nix`: host feature toggles like `enableExtras`
- `config/packages.nix`: system and user packages
- `config/xo.nix`: XO config file and TLS settings
- `config/storage.nix`: NFS, CIFS, VHD, and mount behavior
- `config/overrides.nix`: optional local overrides and bootstrap seed values
- `config/menu.nix`: TUI-managed overrides for console changes, applied last

## Dendritic Shape

- `config/compose.nix` merges the editable config fragments into `vars`
- `modules/config/values.nix` exposes `vars` to the rest of the flake
- `modules/topology/classes.nix` and `modules/topology/hosts.nix` declare den schema and hosts
- `modules/aspects/defaults.nix` sets global den defaults like hostname wiring and HM state
- `modules/aspects/host.nix` and `modules/aspects/user.nix` extend the actual host/user aspects created by den
- `modules/outputs/` contains flake apps and the extras-gated dev shell
- `modules/nixos/` and `modules/home/` hold plain implementation modules

## Common Commands

```bash
./scripts/show-diff.sh
./scripts/commit-config.sh "Describe the change"
./scripts/apply-config.sh
nix run .#menu

nix flake check --no-write-lock-file
```

First install without the bootstrap helper:

```bash
./scripts/apply-config.sh --first-install
```

## Layout

```text
system/
├── config/
│   ├── compose.nix
│   └── *.nix             # editable host policy
├── modules/
│   ├── topology/         # den schema + host declarations
│   ├── aspects/          # den default + host/user aspect extensions
│   ├── outputs/          # apps + dev shell
│   ├── nixos/            # plain NixOS modules
│   └── home/             # plain Home Manager modules
├── scripts/
│   ├── bootstrap.sh
│   ├── apply-config.sh
│   └── *.sh
└── flake.nix
```

## Notes

- `hardware-configuration.nix` is machine-generated and should only be replaced by the bootstrap/manual install flow.
- `nixoaCore` remains the immutable library input. Host-specific policy belongs here in `system/`.
- No `denful` namespace is exported here because the flake is a concrete host configuration, not a reusable aspect library.
- Interactive SSH logins for the managed user open a ratatui-based admin console. The dashboard surfaces repo drift, rebuild state, flake input update checks, RAM usage, root storage usage, and the primary IPv4 address.
- The console still writes to `config/menu.nix` for live edits, auto-commits relevant mutations, exposes rollback as action `0`, and exposes manual `nix-collect-garbage -d` through action `g`.
