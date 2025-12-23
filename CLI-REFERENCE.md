# NiXOA CLI Reference

Complete command reference for the `nixoa` command-line tool.

## Table of Contents

- [Configuration Commands](#configuration-commands)
- [System Commands](#system-commands)
- [Information Commands](#information-commands)
- [Common Workflows](#common-workflows)
- [Examples](#examples)

## Configuration Commands

Manage your NiXOA configuration files.

### `nixoa config edit`

Opens configuration files in your default editor (`$EDITOR` or `nano`).

```bash
nixoa config edit
```

Interactive menu:
- **1** - Edit `configuration.nix` (main system configuration)
- **2** - Edit `config.nixoa.toml` (optional XO server overrides)
- **both** - Edit both files

### `nixoa config show`

Show uncommitted changes to configuration files.

```bash
nixoa config show
nixoa config diff    # Alias for 'show'
```

Displays a git diff of changes to `configuration.nix` and `config.nixoa.toml`.

### `nixoa config commit <message>`

Commit configuration changes to git.

```bash
nixoa config commit "Updated firewall ports"
```

- Auto-initializes git repository if needed
- Shows a summary of changes before committing
- Only commits if there are actual changes

### `nixoa config apply <message>`

Commit configuration changes and rebuild the system in one step.

```bash
nixoa config apply "Enabled Docker and added packages"
```

This is equivalent to:
```bash
nixoa config commit "message"
nixoa rebuild
```

### `nixoa config history`

View the configuration change history.

```bash
nixoa config history
```

Shows the last 10 commits affecting configuration files with:
- Commit hash
- Commit message
- Graph of commit history

**See full diff of a commit:**
```bash
git show <commit-hash>
```

**Revert to a previous commit:**
```bash
cd /etc/nixos/nixoa/user-config
git checkout <commit-hash> -- configuration.nix config.nixoa.toml
nixoa config apply "Reverted to previous config"
```

### `nixoa config status`

Show git repository status.

```bash
nixoa config status
```

Displays:
- Modified files
- Untracked files
- Current branch
- Commits ahead/behind (if tracking a remote)

## System Commands

Manage the NiXOA CE system itself.

### `nixoa rebuild [mode]`

Rebuild the NiXOA CE system.

```bash
nixoa rebuild           # Default: switch
nixoa rebuild switch    # Activate new config and make it default
nixoa rebuild test      # Activate but don't make it default (won't persist reboot)
nixoa rebuild boot      # Don't activate now, use on next boot
```

**Modes:**
- **switch** (default) - Activate immediately and set as default
- **test** - Activate immediately but revert on reboot
- **boot** - Set as default but don't activate until reboot

### `nixoa update`

Update all flake inputs and optionally rebuild.

```bash
nixoa update
```

Steps:
1. Updates `flake.lock` with latest versions
2. Shows what changed
3. Asks if you want to rebuild immediately

**Update specific input:**
```bash
cd /etc/nixos/nixoa/nixoa-vm
nix flake lock --update-input xoSrc
nixoa rebuild
```

### `nixoa rollback`

Rollback to the previous system generation.

```bash
nixoa rollback
```

Immediately activates the previous working configuration. Useful when:
- New config causes issues
- Service fails to start
- Quick recovery needed

### `nixoa list-generations`

List all available system generations.

```bash
nixoa list-generations
nixoa generations          # Alias
```

Shows:
- Generation number
- Date and time created
- Whether it's the current generation

**Switch to specific generation:**
```bash
sudo nixos-rebuild switch --rollback --generation <number>
```

## Information Commands

Get information about your NiXOA CE system.

### `nixoa status`

Show comprehensive system status.

```bash
nixoa status
```

Displays:
- System information (hostname, NixOS version, kernel)
- Service status (xo-server, redis-xo)
- Configuration paths
- Last configuration change

### `nixoa version`

Show version information.

```bash
nixoa version
nixoa --version
nixoa -v
```

### `nixoa help`

Show complete help message with all commands.

```bash
nixoa help
nixoa --help
nixoa -h
```

## Common Workflows

### First-Time Setup

```bash
# 1. Edit configuration
nixoa config edit

# 2. Review changes
nixoa config show

# 3. Apply
nixoa config apply "Initial setup"
```

### Change Network Ports

```bash
# Edit XO settings in configuration.nix
nixoa config edit  # Choose option 1

# Find systemSettings.xo and update port/httpsPort values
# Save and exit

# Apply changes
nixoa config apply "Changed HTTP port to 8080"
```

### Enable a Service

```bash
# Edit system settings in configuration.nix
nixoa config edit  # Choose option 1

# Add to systemSettings.services.definitions or update xo config
# Save and exit

# Apply
nixoa config apply "Enabled Docker"
```

### Add System Packages

```bash
nixoa config edit  # Edit configuration.nix (Choose option 1)
# Add packages to systemSettings.packages.system.extra = [...]
# Or user packages to userSettings.packages.extra = [...]
nixoa config apply "Added htop and vim"
```

### Weekly Maintenance

```bash
# Check for updates
nixoa update

# If updates available, rebuild
# (nixoa update will prompt automatically)
```

### Troubleshooting

```bash
# Check system status
nixoa status

# View service logs
sudo journalctl -u xo-server -f

# If config broke something, rollback
nixoa rollback

# Or revert specific config change
nixoa config history
# Find the good commit
cd /etc/nixos/nixoa/user-config
git checkout <good-commit> -- configuration.nix config.nixoa.toml
nixoa config apply "Reverted to working config"
```

### Audit Configuration Changes

```bash
# See recent config changes
nixoa config history

# See full diff of specific change
git show <commit-hash>

# Check current uncommitted changes
nixoa config show

# Check git status
nixoa config status
```

## Examples

### Example 1: Complete Configuration Change

```bash
# Edit configuration
nixoa config edit
# Make changes in editor...

# Review what you changed
nixoa config show

# Test the changes without making them permanent
nixoa rebuild test

# If everything works, make it permanent
nixoa rebuild switch

# Commit the config for history
nixoa config commit "Tested and applied new ports"
```

Or in one step:
```bash
nixoa config edit
nixoa config apply "Updated ports"
```

### Example 2: Update and Rollback

```bash
# Update system
nixoa update
# Answer 'y' to rebuild

# Oh no, something broke!
nixoa rollback

# Or check what broke
nixoa status
sudo journalctl -u xo-server -n 50

# Fix config
nixoa config edit
nixoa config apply "Fixed broken config"
```

### Example 3: Managing Multiple Environments

```bash
# Save current config state
nixoa config commit "Production config"

# Make experimental changes
nixoa config edit
# Change settings...
nixoa rebuild test  # Test without committing

# Works? Commit it
nixoa config commit "Experimental feature"
nixoa rebuild switch

# Doesn't work? Just discard
git reset --hard HEAD
# Or rollback the system
nixoa rollback
```

### Example 4: Scheduled Maintenance

```bash
# Weekly update routine
nixoa update              # Update inputs
nixoa config show         # Check for any local changes
nixoa status              # Verify system health
nixoa list-generations    # Check generation count

# If too many generations
sudo nix-collect-garbage -d
```

## Tips and Tricks

### Tab Completion

Bash completion is enabled by default. Use tab to autocomplete:

```bash
nixoa <tab>              # Shows: config rebuild update rollback...
nixoa config <tab>       # Shows: commit apply show diff history...
nixoa rebuild <tab>      # Shows: switch test boot
```

### Set Your Preferred Editor

```bash
export EDITOR=vim        # Or nano, emacs, micro, etc.
nixoa config edit        # Uses your preferred editor
```

Add to `~/.bashrc` to make permanent:
```bash
echo 'export EDITOR=vim' >> ~/.bashrc
```

### Quick Status Check

```bash
alias ns='nixoa status'
ns  # Quick status
```

### Aliases for Common Operations

Add to `~/.bashrc`:
```bash
alias nce='nixoa config edit'
alias ncs='nixoa config show'
alias nca='nixoa config apply'
alias nr='nixoa rebuild'
alias nu='nixoa update'
```

### Before Making Major Changes

```bash
# Save current state
nixoa config commit "Before major changes"

# List current generation number
nixoa list-generations | grep current

# Make changes with peace of mind - you can always rollback!
```

## Troubleshooting

### Command Not Found

If `nixoa` command is not found after installing NiXOA CE:

```bash
# Rebuild to install the CLI
cd /etc/nixos/nixoa/nixoa-vm
sudo nixos-rebuild switch --flake .#nixoa

# Log out and back in, or source your profile
source /etc/profile
```

### Config Directory Not Found

Ensure the config repo is at the expected location:

```bash
ls -la /etc/nixos/nixoa/user-config/
```

If missing, clone it:
```bash
git clone https://codeberg.org/nixoa/user-config.git /etc/nixos/nixoa/user-config
```

### Git Errors

If you get git-related errors:

```bash
cd /etc/nixos/nixoa/user-config

# Check git status
git status

# If repository is broken, reinitialize
rm -rf .git
git init
git add .
git commit -m "Reinitialize repository"
```

## See Also

- [QUICKSTART.md](QUICKSTART.md) - 5-minute getting started guide
- [README.md](README.md) - Complete configuration documentation
- Main repository: https://codeberg.org/nixoa/nixoa-vm
- Issues: https://codeberg.org/nixoa/nixoa-vm/issues
