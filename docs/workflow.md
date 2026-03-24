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

## Dev shell (extras enabled)

If `enableExtras = true` in `config/settings.nix`, you can enter the dev shell:

```bash
nix develop
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
2) Wire it into `modules/host.nix` or `modules/user.nix`
3) Add it to the `vm` stack

This keeps edits modular and easy to maintain.
