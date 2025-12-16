# NiXOA Quick Start Guide

Get NiXOA up and running in minutes with the automated bootstrap installer.

## Fastest Path: Automated Installation

Run the bootstrap installer as a regular user:

```bash
# Clone and run installer
git clone https://codeberg.org/nixoa/nixoa-vm.git
cd nixoa-vm/scripts
bash xoa-install.sh
```

The installer will:
1. Clone nixoa-vm flake to `/etc/nixos/nixoa/nixoa-vm`
2. Create user-config in `~/user-config`
3. Generate all Nix modules and TOML templates
4. Copy/generate hardware configuration
5. Create symlink for flake input resolution

Then follow the prompts to complete setup.

## Manual Setup (If Preferred)

### Step 1: Clone Repositories

```bash
# System deployment flake (as root)
sudo mkdir -p /etc/nixos/nixoa
cd /etc/nixos/nixoa
sudo git clone https://codeberg.org/nixoa/nixoa-vm.git

# User configuration (as regular user)
git clone https://codeberg.org/nixoa/user-config.git ~/user-config

# Create symlink
sudo ln -sf ~/user-config /etc/nixos/nixoa/user-config
```

### Step 2: Edit Configuration

```bash
cd ~/user-config
nano system-settings.toml
```

**Required changes:**
- Add your SSH public keys to `admin.sshKeys = [...]`
- Set your `hostname` and `admin.username`

**Optional changes:**
- Network ports, storage settings, packages, services, etc.

### Step 3: Apply Configuration

```bash
# Commit and rebuild in one command
./scripts/apply-config.sh "Initial configuration"
```

That's it! Your NiXOA CE system is now configured.

## Common Tasks

### Change Network Ports

```bash
nixoa config edit                           # Edit xo-server-settings.toml
# Change [xo] port = 80 to your desired port
nixoa config apply "Changed HTTP port"
```

### Add System Packages

```bash
nixoa config edit                           # Edit system-settings.toml
# Add to [packages.system] extra = ["htop", "vim"]
nixoa config apply "Added system packages"
```

### Enable Docker

```bash
nixoa config edit                           # Edit system-settings.toml
# Add to [services] enable = ["docker"]
nixoa config apply "Enabled Docker"
```

### View Configuration Changes

```bash
nixoa config show                           # See uncommitted changes
nixoa config history                        # See past changes
```

### Update System

```bash
nixoa update                                # Update all inputs + rebuild
```

## CLI Quick Reference

```bash
# Configuration
nixoa config edit                           # Edit config files
nixoa config show                           # Show uncommitted changes
nixoa config commit "message"               # Commit changes
nixoa config apply "message"                # Commit + rebuild
nixoa config history                        # View change history

# System Management
nixoa rebuild                               # Rebuild system
nixoa update                                # Update inputs + rebuild
nixoa rollback                              # Rollback to previous
nixoa status                                # Show system status

# Help
nixoa help                                  # Show full help
```

## Troubleshooting

**Changes not applied?**
```bash
nixoa config show      # Check if changes are committed
nixoa rebuild          # Manual rebuild if needed
```

**Want to undo changes?**
```bash
nixoa config history   # Find the commit to revert to
cd ~/user-config
git checkout <commit> -- system-settings.toml xo-server-settings.toml
nixoa config apply "Reverted to previous config"
```

**Service not starting?**
```bash
nixoa status                               # Check service status
sudo systemctl status xo-server            # Detailed service logs
sudo journalctl -u xo-server -f            # Follow logs
```

## Next Steps

- Read the full [README.md](README.md) for advanced configuration
- Explore automated updates, custom services, and more
- Check out the [NiXOA documentation](https://codeberg.org/nixoa/nixoa-vm)

## Support

- Issues: https://codeberg.org/nixoa/nixoa-vm/issues
- Docs: https://codeberg.org/nixoa/nixoa-vm
