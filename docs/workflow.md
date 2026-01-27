# Workflow

A simple day-to-day workflow for NiXOA system changes.

## Edit settings

Update files under `config/`:

- `config/settings.nix`
- `config/packages.nix`
- `config/xo.nix`
- `config/storage.nix`

## Review changes

```bash
./scripts/show-diff.sh
```

## Commit (optional)

```bash
./scripts/commit-config.sh "Describe your change"
```

## Apply

```bash
./scripts/apply-config.sh "Apply config"
```

## Update inputs

```bash
nix flake update
./scripts/apply-config.sh "Update inputs"
```

## Add a custom module

1) Create `modules/host/custom.nix`
2) Register it in `parts/nix/registry/module-registry.nix`
3) Add it to the `vm` stack

This keeps edits modular and easy to maintain.
