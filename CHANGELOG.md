# system v1.2.0 - Centralized Settings & Architecture Improvements

**Release Date:** January 9, 2026

## ✨ Added

- **Centralized settings.nix** - All user configuration now in single root-level settings.nix file
  - System identification (hostname, timezone, stateVersion)
  - User accounts and SSH keys
  - Feature toggles (enableExtras, enableXenGuest, enableXO)
  - System and user packages (directly configurable)
  - Networking & firewall settings
  - Xen Orchestra configuration
  - Boot configuration
  - Storage backends (NFS, CIFS, VHD)
- **Flake-parts modular architecture** - Converted flake.nix to flake-parts structure with dynamic imports
  - Extracted nixosConfigurations into dedicated flake-parts module
  - Extracted apps into separate module for better organization
  - Extracted systems definitions for modularity
- **Direct package exports** - libvhdi and xen-orchestra-ce now available as pkgs.nixoa.* packages
- **Cachix precompiled packages** - Binary cache support for libvhdi and xen-orchestra-ce
  - Eliminates 45+ minute build time for Xen Orchestra
  - Downloads precompiled binaries in seconds
- **Core package overlay** - Automatic availability of pkgs.nixoa.* packages system-wide

## 🔄 Changed

- **Flake renamed** - user-config → system (reflects role as primary system configuration entry point)
- **Configuration architecture**:
  - Centralized all settings in settings.nix (imported by flake.nix)
  - System packages configurable via vars.systemPackages
  - User packages configurable via vars.userPackages
  - Removed inline vars definition from flake.nix
- **Configuration simplification**:
  - Removed unused variables: xoHttpPort, xoHttpsPort, redirectToHttps (defined in config.nixoa.toml)
  - Replaced three variables (enableTLS + redirectToHttps + autoGenerateCerts) → single enableAutoCert option
  - Removed shell = "bash" variable (enableExtras now controls both enhanced tools and zsh)
- **Home Manager refinements**:
  - Removed home-manager SSH configuration (now handled at NixOS system level)
  - ZSH configuration now controlled by vars.enableExtras
  - Cleaned up oh-my-posh options when extras are enabled
  - User packages now read from settings.nix (vars.userPackages)
- **Hardware configuration** - Fixed and committed hardware-configuration.nix for proper Xen VM setup

## 🗑️ Removed

- **Automatic updates** - All update automation removed from system flake
  - Updates now managed via core git releases (stable, beta branches)
  - Future release will include TUI-based update management
  - Removed all updatesAutoUpgrade*, updatesNixpkgs*, updatesXoa*, updatesLibvhdi* variables

## 🐛 Fixed

- Deprecated system references updated throughout codebase
- Flake lock file updated to use beta branch of nixoa-core
- nixfmt optimizations applied for consistent code formatting

## 📚 Migration

- **Determinate Nix** - Migrated to Determinate Nix with stable nixpkgs channel
  - Includes automatic garbage collection for old generations
  - Better binary cache integration
- **Flake inputs** - Updated core input path after core repository refactoring
- **Settings migration** - Edit settings.nix instead of flake.nix for all configuration changes

---

# user-config v1.1.0 - Feature Enhancement Release

**Release Date:** December 29, 2025

## ✨ Added

- `configNixoaFile` option to link `config.nixoa.toml` to `/etc/xo-server/`
- Snitch network monitor integration in home.nix for real-time connection tracking
- Boot toggle option with systemd-boot as default (bios possible but untested)
- Meta attributes to flake apps for better discoverability

## 🔄 Changed

- Migrated snitch from system-level to user-level configuration (home.nix)
- Enhanced home.nix conditional configuration logic for better maintainability
- Improved extras toggle handling with proper shell initialization
- Simplified home.nix to remove obsolete `systemSettings.userPackages` pattern

## 🐛 Fixed

- Home Manager syntax issues in configuration
- Interactive diffFilter line causing errors during diffs
- FZF preview configuration now properly initialized through shell
- Nested configuration structure issues in home.nix

## 🗑️ Removed

- Unnecessary `xoSrc` and `libvhdiSrc` from specialArgs
- Problematic interactive.diffFilter configuration

## 📚 Documentation

- Updated all references: `system-settings.toml` → `configuration.nix`
- Updated all references: `xo-server-settings.toml` → `config.nixoa.toml`

---

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