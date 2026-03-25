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

## Apply

```bash
./scripts/apply-config.sh
```

Before rebuilding, `apply-config.sh` checks for repo changes and runs
`commit-config.sh` when it finds them. That stages the tracked repo paths,
prompts for a commit message, and auto-generates one from the changed file list
if you leave the prompt blank. Use `--dry-run` for a preview or `--build` for a
build-only pass.

## Commit Without Rebuilding

```bash
./scripts/commit-config.sh "Describe the host change"
```

## Extend The Host

- Add NixOS implementation modules under `modules/nixos/`
- Import them from `modules/aspects/host.nix`
- Add Home Manager features under `modules/home/`

This keeps the host topology stable while policy evolves in small modules.
