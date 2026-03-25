# system v3.0.0 - Den-Native Naming And Topology Cleanup

**Release Date:** March 25, 2026

## ⚠️ Breaking Changes

- **Host and user aspect names now follow the actual topology names** instead of the old `nixoaHost` / `nixoaUser` aliases
- **Plain module paths moved** from `modules/_nixos/` and `modules/_homeManager/` to `modules/nixos/` and `modules/home/`
- **Top-level wrapper modules were removed**; `flake.nix` now imports the real dendritic directories directly

## ✨ Added

- **Host-owned account modules** for administrator account, SSH policy, and sudo policy under `modules/nixos/host/`
- **`hostSystem` in `config/site.nix`** as the single source of truth for the host platform

## 🔄 Changed

- **Topology defaults naming** from `schema.nix` to `classes.nix`
- **Config arg wiring naming** from `vars.nix` to `values.nix`
- **Home Manager profile layout** from nested profile/features discovery to explicit imports under `modules/home/`
- **README and operational docs** to match the current den wiring and tree names

## 🐛 Fixed

- **Core/system boundary drift** by moving hostname and administrator policy fully into `system`

---

# system v2.0.0 - Release Surface And Public Core Tracking Cleanup

**Release Date:** March 24, 2026

## ⚠️ Breaking Changes

- **Config entrypoint renamed** from `config/default.nix` to `config/compose.nix`
- **Host policy split** from `config/settings.nix` into `site.nix`, `platform.nix`, and `features.nix`
- **Top-level dendritic module entrypoints renamed and regrouped** under `config`, `topology`, `aspects`, and `outputs`
- **Operational scripts changed behavior** so apply/commit/bootstrap follow the new repository-local workflow

## ✨ Added

- **Versioned release documentation** for the post-refactor system layout
- **Bootstrap-first README flow** condensed around the copy-paste installer path

## 🔄 Changed

- **README and onboarding docs** condensed around the new config/topology/aspect/output structure
- **System release series** advanced for the stabilized dendritic host layout
- **`nixoaCore` consumption** prepared to track the pushed public `beta` branch revision

## 🐛 Fixed

- **Documentation drift** after the topology/aspect/output refactor by aligning the release docs with the current tree and bootstrap workflow

---

# system v1.5.0 - Topology/Aspect Split And Bootstrap Workflow

**Release Date:** March 24, 2026

## ✨ Added

- **Explicit config split** with `config/site.nix`, `config/platform.nix`, `config/features.nix`, and `config/overrides.nix.example`
- **Stable topology modules** under `modules/topology/` with a separate schema module
- **Dedicated output modules** under `modules/outputs/` for apps and the extras-gated dev shell
- **Bootstrap helper** at `scripts/bootstrap.sh` for fresh-host installation and first-switch automation
- **Shared script helpers** in `scripts/lib/common.sh`

## 🔄 Changed

- **Policy/topology separation** by using stable `nixoaHost` and `nixoaUser` aspects instead of mutable hostname/username aspect names
- **Apply workflow** so `scripts/apply-config.sh` now actually runs `nixos-rebuild`
- **Commit workflow** so `scripts/commit-config.sh` only manages git commits and no longer initializes repositories
- **Flake apps** now wrap checkout-local scripts instead of embedding store copies that lose repo context
- **Docs and README** updated for the new dendritic naming scheme and one-line bootstrap flow

## 🗑️ Removed

- **`config/settings.nix`** in favor of the explicit config split
- **Old `config/default.nix` naming** in favor of `config/compose.nix`
- **Legacy `_user/` layout** in favor of `_homeManager/profile/`

---

# system v1.4.0 - Config Composition Split

**Release Date:** February 27, 2026

## ✨ Added

- **config/settings.nix** to consolidate host identity, user, feature, boot, and networking settings
- **Directory-based Home Manager imports** for `modules/user/home/` and `modules/user/home/shell/`
- **Redis to Valkey migration helper** at `scripts/migrate-redis-to-valkey.sh`
- **Optional extras dev shell** (`nix develop`) when `enableExtras = true`
- **UDP firewall ports** support in host firewall module

## 🔄 Changed

- **Config composition** now comes from `config/settings.nix`, `config/packages.nix`, `config/xo.nix`, and `config/storage.nix`
- **Feature registry/lib namespace** moved to `config.nixoa.registry` and `config.nixoa.lib`
- **Flake input source-of-truth** kept in `parts/nix/inputs/core.nix`; regenerated `flake.nix` from `flake-file`
- **Direct `xen-orchestra-ce` system input** removed; now handled through the core input graph
- **Input locking and transport** refreshed (beta updates for `nixoaCore`/`xen-orchestra-ce`, URL normalization to HTTPS)
- **Docs/README/workflow** updated for layout, dev shell, and composition flow

## 🐛 Fixed

- **Infinite recursion** in flake-parts/registry evaluation by decoupling systems and vars bootstrap from registry self-reference
- **Input follow wiring** and generated flake consistency after input graph changes
- **Extras gating** now controls `snitch` and `yq-go`; removed standalone `modules/user/snitch.nix`

---

# system v1.3.0 - Dendritic Host Reorg

**Release Date:** January 27, 2026

## ✨ Added

- **Feature categories** for the host layer: foundation, core, host, user
- **Dendritic module layout** aligned with core's feature registry

## 🔄 Changed

- **configuration.nix** is now the single source of truth (renamed from settings.nix)
- **Tooling packages** moved from core into `configuration.nix` (codex, claude-code)
- **Module layout** reorganized:
  - `modules/features/system/*` → `modules/features/host/*`
  - `modules/features/shared/args.nix` → `modules/features/foundation/args.nix`
  - `modules/features/system/core-appliance.nix` → `modules/features/core/appliance.nix`
- **Core/host boundary** clarified; Xen guest support moved into core virtualization features
- **README + docs** refreshed for the new layout

## 🗑️ Removed

- **System-local xen-guest module** (now provided by core)

---

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

- **Flake renamed** - now standardized as the system flake (primary configuration entry point)
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

# system v1.1.0 - Feature Enhancement Release

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

# system v1.0.0 - Architecture Release Notes

**Release Date:** December 24, 2025

## 🎉 Major Architectural Change: Becomes Primary Entry Point

This release represents a fundamental restructuring of the system flake, elevating it from a data export repository to the **primary entry point** for system configuration and rebuilds.

---

## What Changed

### Before (v0.x - Data Export Role)
```
system (data repository)
├── Exports: Configuration data (specialArgs only)
├── Contains: configuration.nix, config.nixoa.toml
├── Location: /etc/nixos/nixoa-core
└── Usage: Imported by nixoa-core as input
```

### After (v1.0 - Entry Point Role)
```
system (configuration entry point) ✅
├── Exports: nixosConfigurations (system configurations)
├── Imports: nixoa-core as module library
├── Contains: home-manager config, system settings
├── Location: ~/system (your home directory)
└── Usage: Primary flake for system rebuilds
```

---

## Key Changes in This Release

### 🆕 New Flake Exports
- **`nixosConfigurations.${hostname}`** - System configuration (exported from here now, not nixoa-core)
- Full NixOS system definition combining:
  - nixoa-core modules (core, xo system modules)
  - Home Manager configuration (local modules/home.nix)
  - Hardware configuration (local hardware-configuration.nix)
  - User settings (configuration.nix)

### 🆕 New Directory Structure
```
system/
├── modules/
│   └── home.nix           # NEW: Home-manager config (moved from nixoa-core)
├── flake.nix              # CHANGED: Now entry point
├── configuration.nix      # User settings (unchanged)
├── hardware-configuration.nix
├── config.nixoa.toml      # XO config (unchanged)
└── scripts/
    ├── apply-config.sh    # CHANGED: Rebuilds from ~/system
    └── commit-config.sh   # CHANGED: New rebuild location in output
```

### 🆕 New Flake Inputs
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  # NEW: Import nixoa-core as module library
  nixoa-core = {
    url = "path:/etc/nixos/nixoa-core";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # NEW: Get home-manager from nixoa-core
  home-manager.follows = "nixoa-core/home-manager";
};
```

### 🆕 New Home-Manager Module Location
- **Before**: `nixoa-core/modules/home/home.nix` (system-wide)
- **After**: `system/modules/home.nix` (personal configuration)
- **Benefit**: Your shell, packages, and tools are part of system, not system

### 🔄 Updated: Helper Scripts
- **apply-config.sh**: Now rebuilds from current directory (~/system)
- **commit-config.sh**: Updated instructions reference new location
- Both scripts now run `sudo nixos-rebuild switch --flake .#hostname` from system

### 🔄 Updated: Installation Workflow
- Removed symlink creation (no longer needed)
- System clones directly to `~/system` (home directory)
- More intuitive: all user edits happen in one place

### 📚 Updated: Documentation
- README.md: Explains new entry point role
- Removed symlink references (no longer applicable)
- Clarified modules/home.nix location
- Updated rebuild examples and directory structure
- Added notes about flake.nix being the entry point

---
