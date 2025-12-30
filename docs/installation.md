# Installation Guide

Detailed setup instructions for user-config.

## Prerequisites

Before starting, ensure:
- NiXOA modules are installed at `/etc/nixos/nixoa-vm`
- You have a NixOS system running
- You have SSH access (or local console)
- You have internet connection
- You have basic Linux comfort

## Step 1: Clone user-config

Clone to your home directory:

```bash
git clone https://codeberg.org/nixoa/user-config.git ~/user-config
cd ~/user-config
```

Verify the clone:

```bash
ls -la ~/user-config/
# Should show:
# -rw-r--r-- configuration.nix
# -rw-r--r-- flake.nix
# -rw-r--r-- config.nixoa.toml (empty)
# drwxr-xr-x modules/
# drwxr-xr-x scripts/
# etc.
```

## Step 2: Hardware Configuration

NixOS generates hardware configuration during installation. You need to copy it.

### Check If It Exists

```bash
ls -la /etc/nixos/hardware-configuration.nix
```

If missing, generate it:

```bash
sudo nixos-generate-config
ls -la /etc/nixos/hardware-configuration.nix
```

### Copy to user-config

```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/user-config/
sudo chown $USER:$USER ~/user-config/hardware-configuration.nix
sudo chmod 644 ~/user-config/hardware-configuration.nix
```

Verify:

```bash
ls -la ~/user-config/hardware-configuration.nix
```

### Commit to Git

```bash
cd ~/user-config
git add hardware-configuration.nix
git commit -m "Add hardware configuration"

# Verify it's committed
git log --oneline | head -5
```

## Step 3: Initial Configuration

### Create Configuration File

If `configuration.nix` doesn't exist, create it:

```bash
cat > ~/user-config/configuration.nix <<'EOF'
{ lib, pkgs, ... }:

{
  userSettings = {
    packages.extra = [];
    extras.enable = false;
  };

  systemSettings = {
    # REQUIRED: Change these values
    hostname = "nixoa";
    username = "xoa";
    timezone = "UTC";
    stateVersion = "25.11";
    sshKeys = [
      # Paste your SSH public key here
      # ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...
    ];

    # Xen Orchestra
    xo.port = 80;
    xo.httpsPort = 443;

    # Storage
    storage.nfs.enable = true;
    storage.cifs.enable = true;
    storage.vhd.enable = true;

    # Other settings...
  };
}
EOF
```

### Edit Configuration

```bash
nano ~/user-config/configuration.nix
```

**Required changes:**
1. **hostname** - Your system name (e.g., "my-xoa")
2. **username** - Admin user (usually "xoa")
3. **timezone** - Your timezone (e.g., "America/New_York")
4. **stateVersion** - NixOS version (should match `nixos-version --json | jq -r .release`)
5. **sshKeys** - Your SSH public key(s)

### Get Your SSH Public Key

If you have an SSH key already:

```bash
cat ~/.ssh/id_ed25519.pub
# or
cat ~/.ssh/id_rsa.pub
```

Generate a new key if needed:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
# Defaults are fine, just press Enter
cat ~/.ssh/id_ed25519.pub
```

Copy the output (should start with `ssh-ed25519` or `ssh-rsa`) and paste into `sshKeys` array.

### Example Configuration

```nix
{ lib, pkgs, ... }:

{
  userSettings = {
    packages.extra = [];
    extras.enable = false;
  };

  systemSettings = {
    hostname = "my-xoa";
    username = "xoa";
    timezone = "America/New_York";
    stateVersion = "25.11";
    sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI0cQ5xWm... user@laptop"
    ];

    xo = {
      port = 80;
      httpsPort = 443;
      tls = {
        enable = true;
        redirectToHttps = true;
        autoGenerate = true;
      };
    };

    storage = {
      nfs.enable = true;
      cifs.enable = true;
      vhd.enable = true;
      mountsDir = "/var/lib/xo/mounts";
    };

    networking.firewall.allowedTCPPorts = [ 22 80 443 ];

    boot.loader = "systemd-boot";

    packages.system.extra = [];

    updates = {};
  };
}
```

### Verify Configuration

Check syntax before deploying:

```bash
cd ~/user-config
nix flake check .
```

If successful, no output. If there are errors, fix them.

## Step 4: Initialize Git

Initialize git repository:

```bash
cd ~/user-config
git init
git add .
git commit -m "Initial NiXOA configuration"
```

Verify:

```bash
git log --oneline
# Should show your initial commit
```

## Step 5: First Deployment

Deploy your configuration:

```bash
cd ~/user-config
./scripts/apply-config "Initial deployment"
```

**What happens:**
1. Validates configuration syntax
2. Builds NixOS system
3. Switches to new system generation
4. Restarts services

**This takes 5-15 minutes on first run.** Subsequent rebuilds are faster.

### Monitor Progress

In another terminal:

```bash
# Watch build progress
journalctl -f

# Or check specific service
sudo systemctl status xo-server.service
```

## Step 6: Verify Installation

After deployment completes:

```bash
# Check system
uname -a
hostname
whoami

# Check services running
sudo systemctl status xo-server.service
sudo systemctl status redis-xo.service

# Check XO is listening
sudo ss -tlnp | grep -E ':80|:443'

# Test connection
curl -k https://localhost/

# View logs
sudo journalctl -u xo-server -n 30
```

## Step 7: Access Xen Orchestra

Find your system IP:

```bash
hostname -I
```

Then in a browser:

```
https://YOUR-IP/
```

**Default credentials:**
- Username: `admin@admin.net`
- Password: `admin`

**Change the password immediately!**

## Verification Checklist

- [ ] user-config cloned to `~/user-config`
- [ ] hardware-configuration.nix copied
- [ ] configuration.nix edited with your settings
- [ ] SSH keys added to configuration
- [ ] `nix flake check` passes without errors
- [ ] `apply-config` completed successfully
- [ ] `xo-server` service is running
- [ ] Can access HTTPS web interface
- [ ] Can SSH to system as your user

## Troubleshooting Installation

### Git Clone Failed

```bash
# Check git installed
git --version

# Try again
git clone https://codeberg.org/nixoa/user-config.git ~/user-config
```

### Hardware Configuration Not Found

```bash
# Check if exists
ls /etc/nixos/hardware-configuration.nix

# Generate if missing
sudo nixos-generate-config
sudo cp /etc/nixos/hardware-configuration.nix ~/user-config/
sudo chown $USER:$USER ~/user-config/hardware-configuration.nix
```

### Configuration Syntax Error

```bash
# Check syntax
cd ~/user-config
nix flake check .

# If error, look for:
# - Missing semicolons at end of lines
# - Unclosed brackets/braces
# - Quotes around strings in wrong places
```

### Deployment Failed

```bash
# Check what went wrong
sudo journalctl -xe

# See full error
sudo nixos-rebuild switch --flake .#HOSTNAME -L

# Rollback if needed
sudo nixos-rebuild switch --rollback
```

### SSH Key Doesn't Work

```bash
# Verify key is in authorized_keys
sudo cat /home/xoa/.ssh/authorized_keys

# Should show your public key from configuration.nix
# If missing, re-run apply-config
./scripts/apply-config "Added SSH key"
```

### Scripts Not Executable

```bash
chmod +x ~/user-config/scripts/*.sh
chmod +x ~/user-config/commit-config
chmod +x ~/user-config/apply-config
chmod +x ~/user-config/show-diff
chmod +x ~/user-config/history
```

## Next Steps

- **[Daily Workflow](./workflow.md)** - How to make changes
- **[Configuration Guide](./configuration.md)** - All configuration options
- **[Common Tasks](./common-tasks.md)** - Configuration examples
- **[Troubleshooting](./troubleshooting.md)** - Fix common problems
