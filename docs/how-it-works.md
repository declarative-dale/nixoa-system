# How It Works

NiXOA system is the concrete den host flake. It takes editable config fragments,
builds `vars`, attaches stable aspects, and emits
`nixosConfigurations.<hostname>`.

## High-Level Flow

```text
config/*.nix
   -> config/compose.nix
   -> modules/config/vars.nix
   -> modules/topology/schema.nix
   -> modules/topology/hosts.nix
   -> modules/aspects/nixoa-host.nix + modules/aspects/nixoa-user.nix
   -> den host/user contexts
   -> flake.nixosConfigurations.<hostname>
```

## System/Core Boundary

- `system/`: editable host policy, repo scripts, docs, and bootstrap flow
- `core/`: immutable module stacks, overlays, and packages

The host aspect imports:

- `inputs.nixoaCore.nixosModules.appliance`
- `inputs.nixoaCore.overlays.nixoa`
- local runtime, hardware, package, and firewall modules

## Stable Aspect Names

The host and user are declared with stable aspect names rather than reusing the
mutable hostname and username:

- host aspect: `nixoaHost`
- user aspect: `nixoaUser`

That keeps topology identity separate from policy identity, which is closer to
den’s intended structure.
