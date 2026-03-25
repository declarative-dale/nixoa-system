# How It Works

NiXOA system is the concrete den host flake. It takes editable config fragments,
builds `vars`, attaches stable aspects, and emits
`nixosConfigurations.<hostname>`.

## High-Level Flow

```text
config/*.nix
   -> config/compose.nix
   -> modules/config/values.nix
   -> modules/topology/classes.nix
   -> modules/topology/hosts.nix
   -> modules/aspects/defaults.nix + modules/aspects/host.nix + modules/aspects/user.nix
   -> den host/user contexts
   -> flake.nixosConfigurations.<hostname>
```

## System/Core Boundary

- `system/`: editable host policy, repo scripts, docs, and bootstrap flow
- `core/`: immutable module stacks, overlays, and packages

The host aspect imports:

- `inputs.nixoaCore.nixosModules.appliance`
- `inputs.nixoaCore.overlays.nixoa`
- local runtime, hardware, package, account, SSH, sudo, and firewall modules

## Aspect Ownership

Den already creates an aspect for the declared host and user. The local files
extend those real aspect names directly:

- `modules/aspects/host.nix` extends `den.aspects.${vars.hostname}`
- `modules/aspects/user.nix` extends `den.aspects.${vars.username}`

That keeps the wiring den-native and removes the extra naming layer.
