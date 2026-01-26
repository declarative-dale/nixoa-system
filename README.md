# User Config

Your personal configuration repository for NiXOA. This is where you define your system settings and manage deployments.

## Quick Links

- **Getting Started**: [Setup in 5 Minutes](./docs/getting-started.md)
- **Installation**: [Complete Setup Guide](./docs/installation.md)
- **Configuration**: [Understanding Your Settings](./docs/configuration.md)
- **Daily Workflow**: [Making Changes](./docs/workflow.md)
- **Common Tasks**: [Configuration Examples](./docs/common-tasks.md)
- **Troubleshooting**: [Problem Solving](./docs/troubleshooting.md)
- **How It Works**: [Architecture Overview](./docs/how-it-works.md)

## What is This?

This repository is your **configuration entry point** for NiXOA. You edit your configuration here, then run system rebuilds from this directory. Think of it as the "configuration layer" that defines what your NiXOA system looks like.

## First Time Here?

**Start with:** [Getting Started Guide](./docs/getting-started.md)

It walks you through setup and first deployment in about 5 minutes.

## Already Set Up?

**Check:** [Daily Workflow](./docs/workflow.md) for how to make changes

## Features

- ✅ Version-controlled configuration (git)
- ✅ Declarative system settings (pure Nix)
- ✅ Home Manager integration (your user environment)
- ✅ Easy configuration updates
- ✅ Automatic system rebuilds
- ✅ Rollback capability

## Need Specific Help?

- **Configuration examples**: [Common Tasks](./docs/common-tasks.md)
- **How to make changes**: [Daily Workflow](./docs/workflow.md)
- **Something broken?**: [Troubleshooting](./docs/troubleshooting.md)
- **Understand the system**: [How It Works](./docs/how-it-works.md)

## Repository Structure

```
~/user-config/
├── README2.md                      ← This file
├── configuration.nix               ← Your settings (edit this!)
├── hardware-configuration.nix      ← Your hardware (copy once)
├── config.nixoa.toml               ← Optional overrides
├── flake.nix                       ← Entry point
├── modules/
│   └── home.nix                    ← Home Manager config
├── scripts/
│   ├── apply-config.sh             ← Commit + rebuild
│   ├── commit-config.sh            ← Just commit
│   ├── show-diff                   ← Show changes
│   └── history                     ← View git history
└── docs/                           ← Documentation
    ├── getting-started.md
    ├── installation.md
    ├── configuration.md
    ├── workflow.md
    ├── common-tasks.md
    ├── troubleshooting.md
    └── how-it-works.md
```

## Files You'll Edit

- **configuration.nix** - Your system settings (the main file)
- **config.nixoa.toml** - Optional XO server overrides (rarely needed)
- **modules/features/user/home.nix** - Your shell and user environment (less common)

## Files You Won't Touch

- **flake.nix** - Entry point (don't edit)
- **hardware-configuration.nix** - Generated once, then left alone

## License

Apache 2.0
