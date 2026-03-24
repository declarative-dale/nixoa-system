# Repository Guidelines

## Project Structure & Module Organization
This repository is the NiXOA host configuration layer. Editable policy lives in `config/`, composed by `config/compose.nix`. Den topology lives under `modules/topology/`, stable host/user aspects live under `modules/aspects/`, flake outputs live under `modules/outputs/`, and plain implementation modules live under `modules/_nixos/` and `modules/_homeManager/`. `hardware-configuration.nix` is machine-generated and should be treated as host data, not as reusable module code.

## Build, Test, and Development Commands
- `./scripts/show-diff.sh`: Show pending repository changes relevant to the host configuration.
- `./scripts/commit-config.sh "Message"`: Commit staged NiXOA repository changes.
- `./scripts/apply-config.sh --hostname HOSTNAME`: Rebuild and switch the host configuration.
- `./scripts/apply-config.sh --hostname HOSTNAME --first-install`: First switch with Determinate's install cache override.
- `./scripts/bootstrap.sh --hostname HOSTNAME --username USER --ssh-key "..." --first-switch`: Clone or update the repo, write overrides, and optionally perform the first switch.
- `nix flake check --no-write-lock-file`: Validate the flake without mutating the lock file.

## Coding Style & Naming Conventions
- Keep editable host values in `config/`; do not hardcode host-specific values into reusable implementation modules.
- Use explicit names that describe role and scope, for example `modules/aspects/nixoa-host.nix` or `modules/_nixos/runtime/nix-daemon-settings.nix`.
- Add new Home Manager features under `modules/_homeManager/profile/features/`. Add new NixOS implementation modules under `modules/_nixos/` and import them from `modules/aspects/nixoa-host.nix`.

## Testing Guidelines
- Run `nix flake check --no-write-lock-file` before rebuilds.
- Use `./scripts/apply-config.sh --hostname HOSTNAME --dry-run` when you want a safe preview.
- Validate bootstrap/script changes with `bash -n` before relying on them for first-install flows.

## Commit & Pull Request Guidelines
- Commit messages should be explicit about topology, config, and operational changes.
- If a change affects installation or daily workflow, update the relevant docs in `README.md` and `docs/` in the same commit.

## Agent-Specific Notes
- Keep the system/core boundary clean: reusable appliance behavior belongs in `core`; host policy, docs, and operational scripts belong here.
- Do not reintroduce `denful` outputs unless the repository intentionally becomes a shared aspect library.
