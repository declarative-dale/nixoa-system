# NiXOA CE Quick Start Guide

This guide gets you up and running with NiXOA CE configuration in 5 minutes.

## Prerequisites

- NiXOA CE installed at `/etc/nixos/nixoa-ce`
- This config repo cloned to `/etc/nixos/nixoa-ce-config`

## Step 1: Edit Configuration

```bash
# Open system settings
nixoa config edit
# Choose option 1 for system-settings.toml
```

**Required changes:**
- Add your SSH public keys to `sshKeys = [...]`
- Set your `hostname`, `username`, `timezone`

**Optional changes:**
- Network ports, storage settings, packages, services, etc.

## Step 2: Apply Configuration

```bash
# Commit and rebuild in one command
nixoa config apply "Initial configuration"
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
cd /etc/nixos/nixoa-ce-config
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
- Check out the [NiXOA CE documentation](https://codeberg.org/dalemorgan/nixoa-ce)

## Support

- Issues: https://codeberg.org/dalemorgan/nixoa-ce/issues
- Docs: https://codeberg.org/dalemorgan/nixoa-ce
