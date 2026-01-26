# How It Works

Understand how user-config and nixoa-vm work together.

## Two-Repository System

NiXOA is split into two git repositories with different purposes:

```
┌─────────────────────────────────────┐
│  ~/user-config  (YOUR REPOSITORY)   │
│  - Where you make changes           │
│  - Your personal configuration      │
│  - Version controlled by you        │
└────────────┬────────────────────────┘
             │ imports modules from
             ▼
┌─────────────────────────────────────────────────────────┐
│  /etc/nixos/nixoa-vm  (NiXOA LIBRARY - Immutable)       │
│  - Core NixOS modules                                   │
│  - Xen Orchestra integration                            │
│  - Build system and packages                            │
│  - Never edited manually, only updated via git          │
└─────────────────────────────────────────────────────────┘
```

## Your Repository (user-config)

**Location:** `~/user-config`

**Purpose:** Your personal system configuration and deployment entry point

### What's Inside

```
~/user-config/
├── configuration.nix           ← YOUR SETTINGS (edit this!)
├── hardware-configuration.nix  ← Your hardware (copy once)
├── config.nixoa.toml           ← Optional XO overrides
├── flake.nix                   ← Entry point
├── modules/
│   └── features/
│       └── user/
│           └── home.nix         ← Home Manager config
├── scripts/
│   ├── apply-config.sh
│   ├── commit-config.sh
│   ├── show-diff
│   └── history
└── docs/                       ← Documentation
```

### Your Responsibilities

- Edit `configuration.nix` with your system settings
- Copy `hardware-configuration.nix` once (then don't touch it)
- Commit changes to git
- Run `apply-config` to deploy

### What You Don't Edit

- `flake.nix` - Entry point (managed by NiXOA)
- Anything in nixoa-vm (that's the library)

## The Library (nixoa-vm)

**Location:** `/etc/nixos/nixoa-vm`

**Purpose:** Contains all NiXOA implementation (modules, packages, build system)

### What's Inside

```
/etc/nixos/nixoa-vm/
├── flake.nix                  ← Library entry point
├── modules/
│   └── features/              ← Feature modules
│       ├── system/            ← System features
│       ├── virtualization/    ← VM hardware features
│       ├── xo/                ← XO features
│       └── shared/args.nix     ← Shared module args
├── pkgs/                      ← Package definitions
│   ├── xen-orchestra-ce/
│   └── libvhdi/
└── lib/
    └── utils.nix              ← Utility functions
```

### What This Provides

- **Modules** - Nix code defining options and services
- **Packages** - Xen Orchestra and dependencies
- **Utilities** - Shared functions for configuration

### You Don't Edit This

It's a library, like a library on your system. You use it but don't modify it.

## How Configuration Becomes a System

```
1. You edit ~/user-config/configuration.nix
   ↓
2. You run: ./scripts/apply-config "description"
   ↓
3. Git commits your changes
   ↓
4. Runs: sudo nixos-rebuild switch --flake .#HOSTNAME
   ↓
5. nixos-rebuild reads ~/user-config/flake.nix
   ↓
6. flake.nix imports /etc/nixos/nixoa-vm/flake.nix
   ↓
7. Combines:
   - Your settings from configuration.nix
   - nixoa-vm modules and packages
   - Your hardware config
   ↓
8. NixOS evaluates the full system
   ↓
9. Nix builds all packages and generates config files
   ↓
10. System is switched to new generation
    ↓
11. Services are restarted if needed
    ↓
12. Your system now runs with your configuration!
```

## The Flake System

### What's a Flake?

A "flake" is a reproducible Nix package definition. Think of it like a recipe.

Your flake (user-config/flake.nix):
```
Inputs: nixoa-vm, nixpkgs, home-manager
  ↓
  ├─ nixoa-vm provides modules and packages
  ├─ nixpkgs provides all standard Linux packages
  └─ home-manager provides user environment
  ↓
Output: A complete NixOS system configured with your settings
```

### How Flakes Lock Versions

```
flake.lock
  ↓
  ├─ nixoa-vm locked to specific commit
  ├─ nixpkgs locked to specific version
  └─ home-manager locked to specific version
```

This ensures reproducibility:
- Same flake.lock = Same system every time
- If you upgrade, flake.lock changes
- You can always revert to old flake.lock

## Configuration Inheritance

Your settings flow through the system like this:

```
configuration.nix (your settings)
  │
  ├─ userSettings
  │  └─ flows to Home Manager
  │     └─ configures:
  │        - Shell (zsh, bash)
  │        - User packages (neovim, tmux, etc.)
  │        - Dotfiles (.bashrc, .config/, etc.)
  │
  └─ systemSettings
     └─ flows to nixoa-vm features
        ├─ system/identity.nix uses: hostname, timezone, stateVersion
        ├─ system/boot.nix uses: boot loader settings
        ├─ system/users.nix uses: username, sshKeys
        ├─ system/networking.nix uses: firewall, network defaults
        ├─ system/packages.nix uses: system packages
        ├─ system/services.nix uses: custom services
        ├─ virtualization/xen-hardware.nix uses: Xen guest defaults
        ├─ xo/service.nix uses: xo.* settings
        ├─ xo/storage.nix uses: storage.* settings
        ├─ xo/tls.nix uses: tls settings
        ├─ xo/extras.nix uses: extras settings
        └─ ... more ...
```

## Module System

NiXOA modules define options and implement functionality:

```
Each module defines:
  options.nixoa.something = mkOption { ... };  ← What can be configured
    ↓
    (you provide values in configuration.nix)
    ↓
  config.nixoa.something = <your values>;     ← What you set
    ↓
  Implementation that uses your values
```

Example:

```nix
# In nixoa-vm/modules/features/xo/options.nix
options.nixoa.xo.port = mkOption {
  type = types.int;
  default = 80;
  description = "XO HTTP port";
};

# In nixoa-vm/modules/features/xo/service.nix
config.systemd.services.xo-server = {
  serviceConfig.ExecStart = "xo-server --port ${cfg.xo.port}";
};

# ↓
# You set:
# systemSettings.xo.port = 8080;
# ↓
# Result:
# xo-server runs with --port 8080
```

## File Locations After Deployment

When you apply configuration, files are created/modified:

```
/etc/
├── xo-server/
│   └── config.nixoa.toml    ← Generated from your config.nixoa.toml
│
├── nixos/
│   ├── nixoa-vm/            ← Symlink to /etc/nixos/nixoa-vm
│   └── hardware-configuration.nix ← Your hardware config
│
└── ssl/xo/
    ├── certificate.pem      ← TLS certificate (auto-generated)
    └── key.pem              ← TLS key

/var/lib/xo/
├── app/                     ← XO application
├── data/                    ← XO database
├── mounts/                  ← Remote storage mounts
└── tmp/                     ← Temporary files

/run/redis-xo/
└── redis.sock              ← Redis Unix socket

/nix/store/
├── ...                     ← All built packages (immutable)
└── ...

journalctl
├── xo-server.service logs
├── redis-xo.service logs
└── ... more ...
```

## Version Control

### user-config

```
~/user-config/.git/
  ↓
You control this repository:
  - Commit your configuration changes
  - Push to your remote if desired
  - Revert to older versions
  - See history of changes
```

### nixoa-vm

```
/etc/nixos/nixoa-vm/.git/
  ↓
Points to upstream repository:
  - Pull updates from codeberg.org/nixoa/nixoa-vm
  - Never commit changes locally
  - Just update via `git pull`
```

## Build System (yarn2nix)

Xen Orchestra is built using yarn2nix:

```
xen-orchestra source (from GitHub)
  ↓
yarn.lock (dependency list)
  ↓
pkgs/xen-orchestra-ce/default.nix
  ├─ Parses yarn.lock
  ├─ Downloads all npm packages
  ├─ Builds XO monorepo
  ├─ Applies patches
  ├─ Runs tests
  └─ Creates immutable /nix/store/.../xo-ce
```

Benefits:
- **Reproducible** - Same inputs = Same output every time
- **Cacheable** - Binary cache for pre-built packages
- **Fast** - Cached builds = quick deployments
- **Atomic** - Instant rollback if needed

## Key Design Principles

### 1. Separation of Concerns

**user-config**: What you want
**nixoa-vm**: How to implement it

You don't need to understand nixoa-vm's implementation.

### 2. Reproducibility

Same configuration → Same system every time. No surprises.

### 3. Version Control

All changes tracked in git. See history, revert if needed.

### 4. Declarative

You describe the desired state. NixOS implements it.

```nix
# Declarative (what NixOA uses)
hostname = "my-server";

# NOT imperative
# (don't do this)
run("hostnamectl set-hostname my-server");
```

### 5. Immutability

Nix store packages are immutable. System can safely rollback.

### 6. Modularity

Each concern in its own module. Mix and match as needed.

## Common Workflows

### Making a Change

```
Edit configuration.nix
  ↓
./scripts/apply-config "description"
  ↓
Git commits change
  ↓
nixos-rebuild rebuilds system
  ↓
Services restart
  ↓
Change is applied
```

### Reverting a Change

```
git log --oneline          # Find the good commit
git reset <commit-hash>    # Go back to that state
./scripts/apply-config "Reverted to working state"
  ↓
System goes back to previous configuration
```

### Updating nixoa-vm

```
cd /etc/nixos/nixoa-vm
git pull origin main
  ↓
Update is available to user-config
  ↓
No automatic rebuild unless you trigger it
```

## Troubleshooting

### Why Won't My Change Apply?

```
Did you run ./scripts/apply-config?
  ├─ If no → Run it
  └─ If yes:
    Did git commit succeed?
      ├─ If no → Check git status
      └─ If yes:
        Did nixos-rebuild succeed?
          ├─ If no → Check journalctl -xe
          └─ If yes:
            Did services restart?
              ├─ If no → sudo systemctl restart xo-server
              └─ If yes → Change should be applied!
```

### Why Did nixos-rebuild Fail?

```
Syntax error in Nix?
  → nix flake check .

Package not found?
  → nix search nixpkgs packagename

Out of disk?
  → df -h ; sudo nix-collect-garbage -d

Network timeout?
  → Try again or check internet
```

## See Also

- [Configuration Guide](./configuration.md) - What you can configure
- [Daily Workflow](./workflow.md) - How to make changes
- [Common Tasks](./common-tasks.md) - Practical examples
