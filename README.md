# NiXOA System (Host Configuration)

This repo is the **user-editable, host-specific** layer for NiXOA. You edit it
to define your machine, and it imports the immutable `core/` library.

## Getting Started

Start with the ecosystem guide:
- `../.profile/README.md`

It walks through cloning this repo, editing `config/`, and applying changes.

## Layout (Dendritic)

```
system/
├── configuration.nix          ← aggregates config/* (edit the files below)
├── config/                    ← host settings (edit these)
│   ├── identity.nix
│   ├── users.nix
│   ├── features.nix
│   ├── packages.nix
│   ├── networking.nix
│   ├── xo.nix
│   ├── boot.nix
│   └── storage.nix
├── hardware-configuration.nix ← generated once (do not edit; may be moved)
├── config.nixoa.toml          ← optional XO overrides
├── parts/                     ← dendritic flake-parts modules
├── modules/                   ← host features + Home Manager
├── scripts/                   ← apply/commit/diff helpers
└── docs/                      ← user docs
```

## Feature Sets

The default stack is `vm`, composed from:

- **foundation**: platform selection, overlays, Determinate Nix
- **core**: NiXOA appliance stack (from `core/`)
- **host**: hardware import, package list, firewall ports
- **user**: Home Manager configuration and optional tools

Edit `parts/nix/registry/features.nix` to add/remove features or define new
stacks.

## Common Commands

```bash
./scripts/show-diff.sh
./scripts/commit-config.sh "Message"
./scripts/apply-config.sh "Message"

nix flake check .
sudo nixos-rebuild switch --flake .#HOSTNAME -L
```

## Notes

- `config/` is the **single source of truth** for host settings.
- `hardware-configuration.nix` must not be edited.
- Core is not user-editable; treat it as a library input.

## License

Apache-2.0
