# How It Works

NiXOA system is the **host entrypoint**. It composes your settings with the
immutable `core` library and produces `nixosConfigurations.<hostname>`.

## High-Level Flow

```
config/* ─┐
          ├─ configuration.nix (aggregator)
          └─ vars (specialArgs)
                 │
                 ├─ system feature stack (foundation + core + host + user)
                 └─ nixosSystem -> NixOS config
```

## The Relationship Between System and Core

- **system/**: user-editable, host-specific configuration.
- **core/**: reusable module library and packages (imported as a flake input).

System pulls `core` as `nixoaCore` and imports the `appliance` stack via a tiny
wrapper module (`modules/features/core/appliance.nix`).

## Dendritic Feature Registry

Feature modules and stacks are registered in:

- `parts/nix/registry/features.nix`

Example stack:

```
vm = foundation + core + host + user
```

The registry enables clean feature composition and keeps modules small.

## Special Args and Vars

- `config/` files produce `vars`.
- `vars` is injected into modules via `_module.args` and `specialArgs`.
- Home Manager receives `homeArgs` via `extraSpecialArgs`.

This keeps configuration centralized while modules remain composable.
