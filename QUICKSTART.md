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
1. Clone nixoa-vm flake to `/etc/nixos/nixoa-vm`
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
nano configuration.nix
```

**Required changes:**
- Add your SSH public keys to `systemSettings.sshKeys = [...]`
- Set your `systemSettings.hostname` and `systemSettings.username`

Example:
```nix
systemSettings = {
  hostname = "my-xoa";
  username = "xoa";
  timezone = "UTC";
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@laptop"
  ];
  # ... other settings ...
};
```

**Optional changes:**
- Network ports, storage settings, packages, services, etc. (all in configuration.nix)

### Step 3: Apply Configuration

```bash
# Commit and rebuild in one command
./scripts/apply-config.sh "Initial configuration"
```

That's it! Your NiXOA CE system is now configured.

## Common Tasks

### Change Network Ports

```bash
nano ~/user-config/config.nixoa.toml       # Edit XO server config
# Change port = 80 to your desired port
cd ~/user-config
git add config.nixoa.toml
./apply-config.sh "Changed HTTP port"
```

### Add System Packages

```bash
nano ~/user-config/configuration.nix       # Edit system config
# Add to systemSettings.packages.system.extra = ["htop", "vim"]
cd ~/user-config
git add configuration.nix
./apply-config.sh "Added system packages"
```

### Enable Docker

```bash
nano ~/user-config/configuration.nix       # Edit system config
# Add to systemSettings.services.definitions = { docker = { enable = true; }; }
cd ~/user-config
git add configuration.nix
./apply-config.sh "Enabled Docker"
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
cd ~/user-config
git log --oneline     # Find the commit to revert to
git checkout <commit> -- configuration.nix config.nixoa.toml
./apply-config.sh "Reverted to previous config"
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
