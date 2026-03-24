# How It Works

NiXOA system is the **host entrypoint**. It composes your settings with the
immutable `core` library and produces `nixosConfigurations.<hostname>`.

## High-Level Flow

```
config/* ─┐
          ├─ config/default.nix (aggregator)
          └─ modules/vars.nix
                 │
                 ├─ modules/hosts.nix      -> den.hosts.x86_64-linux.<hostname>
                 ├─ modules/host.nix       -> host NixOS aspect
                 ├─ modules/user.nix       -> user Home Manager aspect
                 └─ den -> nixosConfigurations.<hostname>
```

## The Relationship Between System and Core

- **system/**: user-editable, host-specific configuration.
- **core/**: reusable module library and packages (imported as a flake input).

System pulls `core` as `nixoaCore` and imports the curated
`nixoaCore.nixosModules.appliance` stack from the host aspect.

## Special Args and Vars

- `config/` files produce `vars`.
- `vars` is injected into NixOS modules via the host's custom `instantiate`.
- Home Manager receives `vars` and `inputs` via `home-manager.extraSpecialArgs`.

This keeps configuration centralized while modules remain composable.
