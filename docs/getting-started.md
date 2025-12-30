# Getting Started with user-config

Get your configuration set up and deployed in about 5 minutes.

## Prerequisites

- NiXOA already installed (nixoa-vm cloned to `/etc/nixos/nixoa-vm`)
- Basic terminal comfort
- Your SSH public key

## Step 1: Clone This Repository (1 minute)

```bash
git clone https://codeberg.org/nixoa/user-config.git ~/user-config
cd ~/user-config
```

Verify it cloned:
```bash
ls -la ~/user-config/
# Should show: configuration.nix, flake.nix, scripts/, etc.
```

## Step 2: Copy Hardware Configuration (1 minute)

NixOS generated a hardware config during installation. Copy it:

```bash
sudo cp /etc/nixos/hardware-configuration.nix ~/user-config/
sudo chown $USER:$USER ~/user-config/hardware-configuration.nix
cd ~/user-config
git add hardware-configuration.nix
git commit -m "Add hardware configuration"
```

This is a one-time step. Your hardware config won't change often.

## Step 3: Edit Your Settings (2 minutes)

Open `configuration.nix`:

```bash
nano ~/user-config/configuration.nix
```

**Change these required values in `systemSettings`:**

```nix
systemSettings = {
  hostname = "nixoa";        # ← Usually "nixoa"
  username = "xoa";          # ← Usually "xoa" (XenOrchestra Administrator)
  timezone = "UTC";          # ← Your timezone region (America/Chicago, Europe/Paris, etc)
  sshKeys = [
    "ssh-ed25519 AAAAC3..."  # ← Paste YOUR SSH public key
  ];
  # ... rest of settings
};
```

**To get your SSH public key:**

```bash
# If you already have SSH key
cat ~/.ssh/id_ed25519.pub

# Generate new key if needed
ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub
```

**Copy the output** and paste it into the `sshKeys` array.

## Step 4: Deploy (1 minute)

```bash
cd ~/user-config
./scripts/apply-config "Initial deployment"
```

This will:
1. Commit your changes to git
2. Rebuild the system
3. Restart services

**Sit back and wait.** First deployment takes 5-15 minutes.

## Verify It Worked

After deployment completes:

```bash
# Check XO is running
sudo systemctl status xo-server.service

# View logs
sudo journalctl -u xo-server -n 20

# Test connection
curl -k https://localhost/
```

## Access Xen Orchestra

```
HTTPS: https://YOUR-IP/
HTTP:  http://YOUR-IP/ (redirects to HTTPS)
v6 UI: https://YOUR-IP/v6

Login:
  Username: admin@admin.net
  Password: admin

⚠️ Change the password immediately!
```

## You're Done!

Your NiXOA system is now running with your configuration in version control.

## What's Next?

- **Making changes**: [Daily Workflow Guide](./workflow.md)
- **More configuration options**: [Configuration Guide](./configuration.md)
- **Common examples**: [Common Tasks](./common-tasks.md)
- **Understanding the system**: [How It Works](./how-it-works.md)

## Troubleshooting

### Deployment failed?

```bash
# Check configuration syntax
nix flake check .

# See detailed error
sudo nixos-rebuild switch --flake .#HOSTNAME -L
```

### Can't connect to XO?

```bash
# Check service is running
sudo systemctl status xo-server.service

# View error logs
sudo journalctl -u xo-server -e
```

### SSH key not working?

```bash
# Verify your key was added
sudo cat /home/xoa/.ssh/authorized_keys

# Should show your public key from configuration.nix
```

See [Troubleshooting Guide](./troubleshooting.md) for more help.
