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
    url = "path:/etc/nixos/nixoa-vm";
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
cd /etc/nixos/nixoa-vm
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
- **Entry point**: `/etc/nixos/nixoa-vm/flake.nix`
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
# In /etc/nixos/nixoa-vm/modules/home/home.nix
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