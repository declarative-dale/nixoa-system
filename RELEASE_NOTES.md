# user-config v1.0.0 - Architecture Release Notes

**Release Date:** December 24, 2025

## 🎉 Major Architectural Change: Becomes Primary Entry Point

This release represents a fundamental restructuring of the user-config flake, elevating it from a data export repository to the **primary entry point** for system configuration and rebuilds.

---

## What Changed

### Before (v0.x - Data Export Role)
```
user-config (data repository)
├── Exports: Configuration data (specialArgs only)
├── Contains: configuration.nix, config.nixoa.toml
├── Location: /etc/nixos/nixoa/user-config
└── Usage: Imported by nixoa-vm as input
```

### After (v1.0 - Entry Point Role)
```
user-config (configuration entry point) ✅
├── Exports: nixosConfigurations (system configurations)
├── Imports: nixoa-vm as module library
├── Contains: home-manager config, system settings
├── Location: ~/user-config (your home directory)
└── Usage: Primary flake for system rebuilds
```

---

## Key Changes in This Release

### 🆕 New Flake Exports
- **`nixosConfigurations.${hostname}`** - System configuration (exported from here now, not nixoa-vm)
- Full NixOS system definition combining:
  - nixoa-vm modules (core, xo system modules)
  - Home Manager configuration (local modules/home.nix)
  - Hardware configuration (local hardware-configuration.nix)
  - User settings (configuration.nix)

### 🆕 New Directory Structure
```
user-config/
├── modules/
│   └── home.nix           # NEW: Home-manager config (moved from nixoa-vm)
├── flake.nix              # CHANGED: Now entry point
├── configuration.nix      # User settings (unchanged)
├── hardware-configuration.nix
├── config.nixoa.toml      # XO config (unchanged)
└── scripts/
    ├── apply-config.sh    # CHANGED: Rebuilds from ~/user-config
    └── commit-config.sh   # CHANGED: New rebuild location in output
```

### 🆕 New Flake Inputs
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  # NEW: Import nixoa-vm as module library
  nixoa-vm = {
    url = "path:/etc/nixos/nixoa/nixoa-vm";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # NEW: Get home-manager from nixoa-vm
  home-manager.follows = "nixoa-vm/home-manager";
};
```

### 🆕 New Home-Manager Module Location
- **Before**: `nixoa-vm/modules/home/home.nix` (system-wide)
- **After**: `user-config/modules/home.nix` (personal configuration)
- **Benefit**: Your shell, packages, and tools are part of user-config, not system

### 🔄 Updated: Helper Scripts
- **apply-config.sh**: Now rebuilds from current directory (~/user-config)
- **commit-config.sh**: Updated instructions reference new location
- Both scripts now run `sudo nixos-rebuild switch --flake .#hostname` from user-config

### 🔄 Updated: Installation Workflow
- Removed symlink creation (no longer needed)
- User-config clones directly to `~/user-config` (home directory)
- More intuitive: all user edits happen in one place

### 📚 Updated: Documentation
- README.md: Explains new entry point role
- Removed symlink references (no longer applicable)
- Clarified modules/home.nix location
- Updated rebuild examples and directory structure
- Added notes about flake.nix being the entry point

---

## How This Affects Your Workflow

### System Rebuild (The Big Change)

**Old Workflow (v0.x):**
```bash
# Edit your configuration
cd /etc/nixos/nixoa/user-config
nano configuration.nix

# Commit changes
./scripts/commit-config.sh "My changes"

# Rebuild FROM nixoa-vm directory
cd /etc/nixos/nixoa/nixoa-vm
sudo nixos-rebuild switch --flake .#<hostname>
```

**New Workflow (v1.0):**
```bash
# Edit your configuration in home directory
cd ~/user-config
nano configuration.nix

# Commit changes
./scripts/commit-config.sh "My changes"

# Rebuild FROM user-config directory (same directory!)
cd ~/user-config
sudo nixos-rebuild switch --flake .#<hostname>

# Or use the convenience script
./scripts/apply-config.sh "My changes"  # Does both commit and rebuild
```

### Configuration Location

**Old:**
```
/etc/nixos/nixoa/user-config/
├── configuration.nix
├── hardware-configuration.nix
└── config.nixoa.toml
```

**New:**
```
~/user-config/                    # Your home directory!
├── configuration.nix
├── hardware-configuration.nix
├── config.nixoa.toml
├── modules/
│   └── home.nix                 # Your home-manager config
└── scripts/
```

### Flake Entry Point

**Old:**
- **Entry point**: `/etc/nixos/nixoa/nixoa-vm/flake.nix`
- **Configuration data in**: `/etc/nixos/nixoa/user-config/flake.nix`
- Confusing: two flakes with unclear relationship

**New:**
- **Entry point**: `~/user-config/flake.nix` ✅
- **System definition here**: Imports nixoa-vm modules + local config
- Clear: one entry point, modules from library

---

## What's New: Home-Manager in user-config

Your home-manager configuration is now part of user-config, not a system-wide module!

### Before (v0.x)
```nix
# In /etc/nixos/nixoa/nixoa-vm/modules/home/home.nix
# System-wide configuration
# All users get the same home-manager config
```

### After (v1.0)
```nix
# In ~/user-config/modules/home.nix
# Your personal configuration
# You control your shell, packages, dotfiles
```

### What You Can Now Do
- Customize shell (zsh, bash) per user
- Personal package management in one place
- Control tool configurations (git, vim, etc.)
- Version control your home environment separately

### Home-Manager Settings
The home.nix still receives your settings:
```nix
# From ~/user-config/configuration.nix
userSettings = {
  packages.extra = [ "neovim" "tmux" ];
  extras.enable = true;  # Enhanced terminal
};

systemSettings = {
  username = "xoa";
  timezone = "UTC";
  # ... other system settings
};
```

---

## Benefits of This Architecture

### ✅ Intuitive Workflow
- All edits in `~/user-config/`
- Rebuild from same directory
- Configuration is in home directory (not /etc/nixos/)

### ✅ Clear Responsibility
- **nixoa-vm**: Immutable system modules (updated via git)
- **user-config**: Your configuration (what you edit)

### ✅ Better Organization
- Home-manager config with your settings (not system-wide)
- Everything user-facing in one flake

### ✅ Easier Collaboration
- Share just your `~/user-config/` repo
- No need to sync system modules
- Others can add their own modules to nixoa-vm

### ✅ Simpler Updates
- Update system: `cd /etc/nixos/nixoa/nixoa-vm && sudo git pull`
- Update config: `cd ~/user-config && git pull`
- Rebuild: `cd ~/user-config && sudo nixos-rebuild switch --flake .#`

---

## Breaking Changes ⚠️

This is a **major version release** with breaking changes.

### What Breaks
- ❌ Old path `/etc/nixos/nixoa/user-config` no longer used
- ❌ Cannot import old flake.nix (outputs changed)
- ❌ Old symlinks invalid
- ❌ Flake.lock no longer compatible

### What Stays the Same ✅
- ✅ configuration.nix structure unchanged (same settings)
- ✅ config.nixoa.toml unchanged
- ✅ All modules work the same way
- ✅ Functionality fully preserved

---

## Installation & Setup

### Fresh Installation
Use the automated installer:
```bash
bash <(curl -fsSL https://codeberg.org/nixoa/nixoa-vm/raw/main/scripts/xoa-install.sh)
```

The installer will:
1. Clone nixoa-vm to `/etc/nixos/nixoa/nixoa-vm`
2. Clone user-config to `~/user-config`
3. Set up modules/home.nix
4. Generate hardware configuration
5. Initialize git repository

### Manual Setup
```bash
# Clone user-config to home
git clone https://codeberg.org/nixoa/user-config.git ~/user-config
cd ~/user-config

# Create modules directory
mkdir -p modules

# Copy home-manager config from nixoa-vm
cp /etc/nixos/nixoa/nixoa-vm/modules/home/home.nix modules/

# Copy hardware configuration
sudo cp /etc/nixos/hardware-configuration.nix .
sudo chown $USER:$USER hardware-configuration.nix

# Commit
git add modules/ hardware-configuration.nix
git commit -m "Add home-manager and hardware config"

# Update flake
nix flake update

# First rebuild
sudo nixos-rebuild switch --flake .#$(hostname)
```

---

## Configuration File Reference

### configuration.nix
Your system and user settings in pure Nix:

```nix
{
  # User settings (for home-manager)
  userSettings = {
    packages.extra = [ "vim" "git" ];
    extras.enable = true;  # zsh, modern tools, etc.
  };

  # System settings
  systemSettings = {
    hostname = "my-nixoa";
    username = "xoa";
    timezone = "America/New_York";
    sshKeys = [ "ssh-ed25519 AAAA..." ];
    # ... more options
  };
}
```

### modules/home.nix
Your home-manager configuration:
- Shell setup (zsh, bash)
- User packages and tools
- Dotfile management
- Environment variables
- Program configurations

### config.nixoa.toml
Xen Orchestra server configuration (optional overrides)

---

## Common Tasks

### Update System Modules (nixoa-vm)
```bash
cd /etc/nixos/nixoa/nixoa-vm
sudo git pull
cd ~/user-config
sudo nixos-rebuild switch --flake .#$(hostname)
```

### Update Your Configuration
```bash
cd ~/user-config
nano configuration.nix    # Make changes
git add configuration.nix
git commit -m "Updated settings"
sudo nixos-rebuild switch --flake .#$(hostname)
```

### Update Everything
```bash
cd ~/user-config
# Update flake inputs (get latest nixpkgs, etc.)
nix flake update
# Rebuild with new inputs
sudo nixos-rebuild switch --flake .#$(hostname)
```

### View Configuration Differences
```bash
cd ~/user-config
./scripts/show-diff.sh
```

### View Rebuild History
```bash
cd ~/user-config
./scripts/history.sh
```

---

## Module System Integration

The flake now properly integrates:

### nixoa-vm Modules
- `core/base.nix` - Base NixOS setup
- `core/users.nix` - User management
- `core/networking.nix` - Network config
- `core/packages.nix` - System packages
- `core/services.nix` - System services
- `xo/*` - All Xen Orchestra modules

### Your Modules
- `modules/home.nix` - Home-manager setup
- `hardware-configuration.nix` - Hardware detection

All are combined in your flake.nix when you rebuild.

---

## Technical Details

### Flake Structure
```
outputs = { self, nixpkgs, nixoa-vm, home-manager }
  → nixosConfigurations.${hostname}
    → lib.nixosSystem
      → modules:
        - hardware-configuration.nix (local)
        - nixoa-vm.nixosModules.default (library)
        - home-manager.nixosModules.home-manager
        - modules/home.nix (local)
```

### Data Flow
```
configuration.nix (your settings)
        ↓
    userArgs {
      username, hostname, system
      userSettings, systemSettings
      xoTomlData
    }
        ↓
    Passed to all modules via specialArgs
        ↓
    Home-manager receives via extraSpecialArgs
        ↓
    Merged with nixoa-vm modules
        ↓
    Final system configuration
```

---

## Comparison: Old vs New

| Aspect | v0.x (Old) | v1.0 (New) |
|--------|-----------|-----------|
| **Entry Point** | nixoa-vm/flake.nix | user-config/flake.nix |
| **Configuration Location** | /etc/nixos/nixoa/user-config | ~/user-config |
| **Rebuild Command** | cd /etc/nixos/nixoa/nixoa-vm && rebuild | cd ~/user-config && rebuild |
| **Home-Manager Config** | System-wide (nixoa-vm) | Personal (user-config) |
| **Flake Role** | Data export | Full system config |
| **Dependency** | nixoa-vm → user-config | user-config → nixoa-vm |
| **Symlinks** | Required | Not needed |
| **Module Library** | Tightly coupled | Cleanly separated |

---

## Support & Questions

- 📖 See [README.md](./README.md) for configuration overview
- 📘 See [QUICKSTART.md](./QUICKSTART.md) for 5-minute guide
- 📋 See [CLI-REFERENCE.md](./CLI-REFERENCE.md) for script reference
- 📚 See [nixoa-vm/README.md](../nixoa-vm/README.md) for system guide
- 🔧 See [nixoa-vm/CONFIGURATION.md](../nixoa-vm/CONFIGURATION.md) for module docs

---

## Version History

### v1.0.0 (2025-12-24) - Becomes Entry Point
- **Major**: Now exports nixosConfigurations (was data only)
- **Major**: Location moved to ~/user-config (from /etc/nixos/)
- **Major**: Home-manager config moved here (from nixoa-vm)
- **Changed**: Imports nixoa-vm as module library input
- **Changed**: Rebuild workflow (from nixoa-vm directory to user-config directory)
- **Updated**: All documentation and examples
- **Updated**: Helper scripts

### v0.x (Pre-release)
- Data export flake
- Imported by nixoa-vm

---

## Contributing

NixOA is an open-source project. Contributions welcome!

- Configuration issues: [user-config Issues](https://codeberg.org/nixoa/user-config/issues)
- System module issues: [nixoa-vm Issues](https://codeberg.org/nixoa/nixoa-vm/issues)
- License: Apache License 2.0

---

## Acknowledgments

This architectural change was designed to provide:
- **Clearer separation** between system modules and user configuration
- **Better user experience** with intuitive workflow
- **Easier maintenance** and version control
- **More flexibility** for custom extensions

---

**Made with ❤️ for the NixOS and Xen Orchestra communities**

*This is an experimental project. For production deployments, use the official [Xen Orchestra Appliance (XOA)](https://xen-orchestra.com/).*
