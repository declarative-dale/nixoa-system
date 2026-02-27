# Repository Guidelines

## Project Structure & Module Organization
This repository is the NiXOA user configuration layer. Primary files are `modules/user-configuration.nix` (aggregates `config/`), `hardware-configuration.nix`, and optional `config.nixoa.toml`. Home Manager settings live in `modules/user/home.nix`. Helper scripts are in `scripts/`, and documentation is under `docs/`.

## Build, Test, and Development Commands
- `./scripts/show-diff.sh`: Show pending changes to config files.
- `./scripts/commit-config.sh "Message"`: Commit configuration changes without rebuilding.
- `./scripts/apply-config.sh "Message"`: Commit and rebuild the system.
- `nix flake check .`: Validate flake and configuration syntax.
- `sudo nixos-rebuild switch --flake .#HOSTNAME -L`: Rebuild manually when needed.

## Coding Style & Naming Conventions
- Nix files use 2-space indentation; keep host settings in `config/` and module wiring under `modules/`.
- File naming is fixed: `modules/user-configuration.nix` is the primary aggregator entry point.
- `hardware-configuration.nix` is generated once and should not be edited manually.

## Testing Guidelines
- Run `nix flake check .` before applying changes.
- Use `sudo nixos-rebuild dry-run --flake .#HOSTNAME` for a safe preview when unsure.
- There is no separate test suite; changes are validated through rebuilds.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and sentence case (see `git log`).
- PRs should include a clear description of the configuration change, relevant screenshots (if UI changes), and links to any related issues.

## Agent-Specific Notes
- Treat this repo as the only place for user-specific configuration; core code belongs in the upstream library repo.
