# NiXOA CE Configuration

This is your personal configuration repository for NiXOA CE. It uses easy-to-edit TOML files that are automatically converted to Nix configurations and applied declaratively.

## Overview

This repository provides a simple TOML-based configuration system for NiXOA CE:

**📝 What you edit:**
- `system-settings.toml` - System configuration (hostname, users, SSH keys, services, etc.)
- `xo-server-settings.toml` - Xen Orchestra server configuration (ports, TLS, etc.)

**🔧 What happens automatically:**
- TOML files are read by Nix modules
- System configuration is generated from your settings
- `/etc/xo-server/config.toml` is created declaratively
- All changes are version-controlled in git

## Directory Structure

```
nixoa-ce-config/
├── system-settings.toml           # Edit this: System configuration
├── xo-server-settings.toml        # Edit this: XO server configuration
├── flake.nix                      # Flake definition
├── modules/
│   ├── system.nix                 # Reads system-settings.toml
│   └── xo-server-config.nix       # Reads xo-server-settings.toml
├── scripts/                       # Helper scripts
│   ├── commit-config.sh
│   ├── apply-config.sh
│   ├── show-diff.sh
│   └── history.sh
├── commit-config                  # Convenience wrappers
├── apply-config
├── show-diff
├── history
├── README.md                      # This file
├── QUICKSTART.md                  # 5-minute quick start guide
└── CLI-REFERENCE.md               # Complete CLI command reference
```

> **💡 Tip:** After installing NiXOA CE, use the `nixoa` command for all operations. The scripts are still available for advanced use.

## Quick Start

### 1. Clone this repository

```bash
git clone https://codeberg.org/dalemorgan/nixoa-ce-config.git /etc/nixos/nixoa-ce-config
cd /etc/nixos/nixoa-ce-config
```

### 2. Edit your configuration

**Using the nixoa CLI (recommended):**
```bash
nixoa config edit
```

At minimum, you must:
- Add your SSH public keys to the `sshKeys` array
- Set your `hostname`, `username`, and `timezone`

**Or edit manually:**
```bash
nano system-settings.toml      # System settings
nano xo-server-settings.toml   # XO server settings (optional)
```

### 3. Apply your changes

**Using the nixoa CLI (recommended):**
```bash
nixoa config apply "Initial configuration"
```

**Or using scripts:**
```bash
./apply-config "Initial configuration"
```

**Or manually:**
```bash
./commit-config "Initial configuration"
cd /etc/nixos/nixoa-ce
sudo nixos-rebuild switch --flake .#nixoa
```

> **📖 New to NiXOA CE?** Check out [QUICKSTART.md](QUICKSTART.md) for a 5-minute guide!

## CLI Quick Reference

The `nixoa` command provides an easy interface for all configuration tasks:

```bash
# Configuration Management
nixoa config edit               # Edit configuration files
nixoa config show               # Show uncommitted changes
nixoa config commit "msg"       # Commit changes
nixoa config apply "msg"        # Commit + rebuild
nixoa config history            # View change history
nixoa config status             # Git status

# System Management
nixoa rebuild                   # Rebuild system (switch)
nixoa rebuild test              # Test without switching
nixoa update                    # Update all inputs + rebuild
nixoa rollback                  # Rollback to previous generation
nixoa list-generations          # List available generations

# Information
nixoa status                    # Show system status
nixoa version                   # Show version info
nixoa help                      # Show full help
```

**Tab completion is enabled!** Just type `nixoa <tab>` to see available commands.

> **📖 Complete CLI Documentation:** See [CLI-REFERENCE.md](CLI-REFERENCE.md) for detailed command reference and examples.

## Daily Workflow

### Using the nixoa CLI (Recommended)

1. **Edit configuration:**
   ```bash
   nixoa config edit
   ```

2. **Check what changed:**
   ```bash
   nixoa config show
   ```

3. **Apply changes:**
   ```bash
   nixoa config apply "Updated firewall ports"
   ```

### Using Scripts Directly

1. **Edit the TOML files:**
   ```bash
   cd /etc/nixos/nixoa-ce-config
   nano system-settings.toml
   nano xo-server-settings.toml
   ```

2. **Check what changed:**
   ```bash
   ./show-diff
   ```

3. **Commit and apply:**
   ```bash
   ./apply-config "Updated firewall ports"
   ```

### Using Helper Scripts

All scripts are executable from the config directory:

**Commit changes:**
```bash
./commit-config "Your commit message"
```

**Commit and apply changes:**
```bash
./apply-config "Your commit message"
```

**Show uncommitted changes:**
```bash
./show-diff
```

**View configuration history:**
```bash
./history
```

### Using Flake Apps (Alternative)

You can also use `nix run` commands:

```bash
cd /etc/nixos/nixoa-ce-config

nix run .#commit "Your commit message"
nix run .#apply "Your commit message"
nix run .#diff
nix run .#history
```

## Configuration Files

### system-settings.toml

This file contains all your system-level settings:

```toml
# Basic settings
system = "x86_64-linux"
hostname = "nixoa"
username = "xoa"
timezone = "UTC"
sshKeys = [
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host"
]

# Networking
[networking.firewall]
allowedTCPPorts = [80, 443, 3389, 5900, 8012]

# Storage
[storage]
mountsDir = "/var/lib/xo/mounts"

[storage.nfs]
enable = true

[storage.cifs]
enable = true

# Updates, packages, services, etc.
```

### xo-server-settings.toml

This file contains XO server-specific settings:

```toml
# HTTP/HTTPS ports
[xo]
host = "0.0.0.0"
port = 80
httpsPort = 443

# TLS configuration
[tls]
enable = true
redirectToHttps = true
autoGenerate = true
dir = "/etc/ssl/xo"
cert = "/etc/ssl/xo/certificate.pem"
key = "/etc/ssl/xo/key.pem"

# Authentication
[authentication]
defaultTokenValidity = "30 days"

# Logging
[logs]
level = "info"  # Options: trace, debug, info, warn, error
```

## Advanced Usage

### Custom Services

Enable NixOS services directly in `system-settings.toml`:

```toml
[services]
enable = ["docker", "tailscale"]

# Or configure with custom options:
[services.docker]
enable = true
enableOnBoot = true

[services.docker.autoPrune]
enable = true
dates = "weekly"
```

### Custom Packages

Add system-wide or user-specific packages in `system-settings.toml`:

```toml
[packages.system]
extra = ["neovim", "htop", "git"]

[packages.user]
extra = ["fzf", "ripgrep"]
```

### Automated Updates

Configure automatic updates in `system-settings.toml`:

```toml
[updates.nixpkgs]
enable = true
schedule = "Mon 04:00"
keepGenerations = 7

[updates.xoa]
enable = true
schedule = "Tue 04:00"

[updates.monitoring.ntfy]
enable = true
server = "https://ntfy.sh"
topic = "my-xoa-updates"
```

### Advanced XO Settings

Customize logging and authentication in `xo-server-settings.toml`:

```toml
[authentication]
defaultTokenValidity = "7 days"

[logs]
level = "debug"  # For troubleshooting

# Advanced path configuration (usually not needed)
[paths]
dataDir = "/var/lib/xo/data"
tempDir = "/var/lib/xo/tmp"
mountsDir = "/var/lib/xo/mounts"
```

## Version Control

Your configuration is automatically version-controlled with git:

### View Configuration History

```bash
./history
```

Or use git directly:
```bash
git log --oneline -- system-settings.toml xo-server-settings.toml
```

### See What Changed in a Commit

```bash
git show <commit-hash>
```

### Revert to a Previous Configuration

```bash
# Revert files to a previous commit
git checkout <commit-hash> -- system-settings.toml xo-server-settings.toml

# Commit the reversion
./commit-config "Reverted to previous configuration"

# Apply
cd /etc/nixos/nixoa-ce
sudo nixos-rebuild switch --flake .#nixoa
```

### Undo Last Commit (Before Applying)

```bash
git reset HEAD~1
```

## Troubleshooting

### Changes not taking effect?

Make sure you've both committed and rebuilt:

```bash
./apply-config "My changes"
# Or separately:
./commit-config "My changes"
cd /etc/nixos/nixoa-ce
sudo nixos-rebuild switch --flake .#nixoa
```

### Configuration not found?

Ensure the config is at `/etc/nixos/nixoa-ce-config`:

```bash
ls -la /etc/nixos/nixoa-ce-config/
```

### TOML syntax errors?

Validate your TOML files before committing:

```bash
# Check for errors when Nix reads the config
nix eval .#nixoa.system
nix eval .#nixoa.xoServer.toml
```

### Git not initialized?

The first time you run `./commit-config`, it will initialize the repository automatically.

### Permission denied on scripts?

Make scripts executable:

```bash
chmod +x commit-config apply-config show-diff history
chmod +x scripts/*.sh
```

## Migration from nixoa.toml

If you're migrating from the old `nixoa.toml` approach:

1. Copy your settings from `nixoa.toml` to `system-settings.toml` and `xo-server-settings.toml`
2. The structure is identical, just split across two files now
3. Commit your new configuration: `./commit-config "Migrated from nixoa.toml"`
4. Rebuild: `cd /etc/nixos/nixoa-ce && sudo nixos-rebuild switch --flake .#nixoa`
5. Once working, you can delete the old `nixoa.toml` (NiXOA CE will use the flake automatically)

## How It Works

Behind the scenes:

1. You edit `system-settings.toml` and `xo-server-settings.toml` (plain TOML files)
2. `modules/system.nix` reads `system-settings.toml` using `builtins.fromTOML`
3. `modules/xo-server-config.nix` reads `xo-server-settings.toml` and generates the XO config structure
4. The flake exports these as `nixoa.system` and `nixoa.xoServer.toml`
5. NiXOA CE reads the flake and:
   - Uses `nixoa.system` for all system settings (via `vars.nix`)
   - Generates `/etc/xo-server/config.toml` from `nixoa.xoServer.toml` (via `modules/xo-config.nix`)
6. On rebuild, everything is applied atomically

**You get declarative configuration with a simple TOML interface!**

## Support

- NiXOA CE Repository: https://codeberg.org/dalemorgan/nixoa-ce
- Config Template Repository: https://codeberg.org/dalemorgan/nixoa-ce-config
- Issues: https://codeberg.org/dalemorgan/nixoa-ce/issues

## License

Apache 2.0 - See LICENSE file
