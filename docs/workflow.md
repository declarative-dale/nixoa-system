# Workflow

## Edit Host Policy

Update files under `config/`:

- `site.nix`
- `platform.nix`
- `features.nix`
- `packages.nix`
- `xo.nix`
- `storage.nix`
- optionally `overrides.nix`

## Review Changes

```bash
./scripts/show-diff.sh
```

## Dev Shell

If `enableExtras = true` in `config/features.nix`:

```bash
nix develop
```

## Commit

```bash
./scripts/commit-config.sh "Describe the host change"
```

## Apply

```bash
./scripts/apply-config.sh --hostname nixoa
```

Use `--dry-run` for a preview or `--build` for a build-only pass.

## Extend The Host

- Add NixOS implementation modules under `modules/nixos/`
- Import them from `modules/aspects/host.nix`
- Add Home Manager features under `modules/home/`

This keeps the host topology stable while policy evolves in small modules.
