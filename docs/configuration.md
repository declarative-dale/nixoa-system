# Configuration Guide

Understand all the configuration options in your `configuration.nix`.

## File Location

```
~/user-config/configuration.nix
```

This is the main file you'll edit to configure your NiXOA system.

## Basic Structure

```nix
{ lib, pkgs, ... }:

{
  userSettings = {
    # User environment (packages, shell)
  };

  systemSettings = {
    # System-wide settings (hostname, XO, storage, etc.)
  };
}
```

## User Settings

Settings for your personal user environment.

### Packages

Add extra packages for your user:

```nix
userSettings.packages.extra = [
  "neovim"
  "tmux"
  "lazygit"
];
```

Each package is a string with the nixpkgs name.

### Extras

Enable enhanced terminal environment:

```nix
userSettings.extras.enable = true;
```

Includes:
- Zsh shell with Oh My Zsh
- Oh My Posh prompt (Darcula theme)
- Tools: fzf, ripgrep, fd, bat, eza, and more
- Developer utilities: lazygit, gh, bottom

## System Settings

System-wide configuration for your entire NiXOA installation.

### Basic Identification

Required settings that identify your system:

```nix
systemSettings = {
  hostname = "my-nixoa";           # System name
  username = "xoa";                # Admin user
  stateVersion = "25.11";          # NixOS version (don't change)
  timezone = "UTC";                # Your timezone
  sshKeys = [                       # SSH public keys
    "ssh-ed25519 AAAAC3..."
  ];
};
```

**hostname:** Your system name. Examples:
- `my-xoa`
- `xeno-box`
- `hypervisor-01`

**username:** Admin user account. Usually `xoa` (the XO service account).

**stateVersion:** NixOS version. Check with:
```bash
nixos-version --json | jq -r .release
# Output: 25.11
```

**timezone:** Your timezone. Examples:
- `UTC`
- `America/New_York`
- `Europe/London`
- `Asia/Tokyo`

Full list: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

**sshKeys:** Your SSH public keys for admin access. Get with:
```bash
cat ~/.ssh/id_ed25519.pub
```

### Xen Orchestra

Configure the XO service:

```nix
systemSettings.xo = {
  port = 80;                        # HTTP port
  httpsPort = 443;                  # HTTPS port

  tls = {
    enable = true;                  # Use HTTPS
    redirectToHttps = true;         # HTTP → HTTPS redirect
    autoGenerate = true;            # Auto-generate self-signed certs
  };

  service = {
    user = "xo";                    # Service user (don't change)
    group = "xo";                   # Service group (don't change)
  };

  host = "0.0.0.0";                 # Bind address (all interfaces)
};
```

**port:** HTTP listening port (usually 80 or 8080)

**httpsPort:** HTTPS listening port (usually 443 or 8443)

**autoGenerate:** Auto-generate self-signed TLS certificates. Set to `false` if you provide your own certificates.

### Storage

Enable remote storage backends:

```nix
systemSettings.storage = {
  nfs.enable = true;                # NFS mount support
  cifs.enable = true;               # CIFS/SMB mount support
  vhd.enable = true;                # VHD/VHDX support
  mountsDir = "/var/lib/xo/mounts"; # Where mounts go
};
```

Enable the storage types you need. All are disabled by default.

### Networking

Configure firewall and network settings:

```nix
systemSettings.networking.firewall.allowedTCPPorts = [
  22    # SSH (admin access)
  80    # HTTP
  443   # HTTPS
  3389  # RDP (optional)
  5900  # VNC (optional)
];

systemSettings.networking.firewall.allowedUDPPorts = [
  # Add UDP ports if needed
];
```

Common ports:
- **22** - SSH (admin access)
- **80** - HTTP
- **443** - HTTPS
- **3389** - RDP (Remote Desktop)
- **5900** - VNC (Remote Desktop)
- **8012** - Custom services

### Boot

Configure boot loader:

```nix
systemSettings.boot.loader = "systemd-boot";  # or "grub"
```

**systemd-boot:** Modern, recommended for UEFI systems

**grub:** Legacy boot loader for older systems

### System Packages

Add system-wide packages:

```nix
systemSettings.packages.system.extra = [
  "htop"
  "git"
  "curl"
  "wget"
];
```

These are available to all users.

### Automated Updates

Configure automatic system updates:

```nix
systemSettings.updates = {
  gc = {
    enable = true;
    schedule = "Sun 04:00";        # Sunday at 4 AM
    keepGenerations = 7;           # Keep 7 generations
  };

  nixpkgs = {
    enable = true;
    schedule = "Mon 04:00";        # Monday at 4 AM
    keepGenerations = 7;
  };

  xoa = {
    enable = true;
    schedule = "Tue 04:00";        # Tuesday at 4 AM
    keepGenerations = 7;
  };
};
```

**gc:** Garbage collection (cleans up unused packages)

**nixpkgs:** Update system packages

**xoa:** Update Xen Orchestra application

**schedule:** When to run (format: "DAY HH:MM" in UTC)

**keepGenerations:** Number of old system generations to keep

## Complete Example

```nix
{ lib, pkgs, ... }:

{
  userSettings = {
    packages.extra = [
      "neovim"
      "tmux"
      "lazygit"
      "ripgrep"
    ];
    extras.enable = true;
  };

  systemSettings = {
    # Basic identification
    hostname = "my-xoa";
    username = "xoa";
    timezone = "America/New_York";
    stateVersion = "25.11";
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5... user@laptop"
    ];

    # Xen Orchestra
    xo = {
      port = 80;
      httpsPort = 443;
      tls = {
        enable = true;
        redirectToHttps = true;
        autoGenerate = true;
      };
    };

    # Storage
    storage = {
      nfs.enable = true;
      cifs.enable = true;
      vhd.enable = true;
      mountsDir = "/var/lib/xo/mounts";
    };

    # Network
    networking.firewall.allowedTCPPorts = [
      22 80 443 3389 5900
    ];

    # Boot
    boot.loader = "systemd-boot";

    # System packages
    packages.system.extra = [
      "htop"
      "git"
    ];

    # Updates
    updates = {
      gc = {
        enable = true;
        schedule = "Sun 04:00";
        keepGenerations = 7;
      };
      nixpkgs = {
        enable = true;
        schedule = "Mon 04:00";
        keepGenerations = 7;
      };
      xoa = {
        enable = true;
        schedule = "Tue 04:00";
        keepGenerations = 7;
      };
    };
  };
}
```

## Optional: TOML Overrides

For some Xen Orchestra settings, you can use `config.nixoa.toml` (optional):

```toml
[redis]
socket = "/run/redis-xo/redis.sock"

[logs]
level = "info"  # trace, debug, info, warn, error

[authentication]
defaultTokenValidity = "30 days"
```

## Validation

Check your configuration for syntax errors:

```bash
cd ~/user-config
nix flake check .
```

No output = success. Errors will be shown.

## Applying Changes

After editing `configuration.nix`:

```bash
cd ~/user-config
./scripts/apply-config "Description of changes"
```

This validates, commits, and rebuilds.

## File Locations

Once applied, your settings are used by nixoa-vm:

```
/etc/xo-server/config.nixoa.toml     ← Generated from your config
/etc/nixos/hardware-configuration.nix ← Your hardware
~/.ssh/authorized_keys                ← Your SSH keys
```

## Common Mistakes

### Syntax Errors

**Missing semicolon:**
```nix
hostname = "my-xoa"  # ✗ Missing ;
hostname = "my-xoa"; # ✓ Correct
```

**Unclosed brackets:**
```nix
packages.extra = [
  "neovim"
  "tmux"
# ✗ Missing ]

packages.extra = [
  "neovim"
  "tmux"
]; # ✓ Correct
```

**Wrong quotes:**
```nix
hostname = 'my-xoa';  # ✗ Single quotes
hostname = "my-xoa";  # ✓ Double quotes
```

### Finding Package Names

Search at: https://search.nixos.org

Or use:
```bash
nix search nixpkgs neovim
```

### Reverting Changes

```bash
cd ~/user-config
git log --oneline        # See commits
git reset HEAD~1         # Undo last change
git checkout -- configuration.nix  # Discard edits
```

## See Also

- [Daily Workflow](./workflow.md) - How to make changes
- [Common Tasks](./common-tasks.md) - Configuration examples
- [Troubleshooting](./troubleshooting.md) - Fix problems
- Full nixoa-vm documentation - `/etc/nixos/nixoa-vm/CONFIGURATION.md`
