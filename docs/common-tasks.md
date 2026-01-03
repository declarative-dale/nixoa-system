# Common Configuration Tasks

Practical examples of common NiXOA configuration changes.

## Adding Packages

### Add User Packages

Packages installed for your user environment:

```nix
userSettings.packages.extra = [
  "neovim"
  "tmux"
  "lazygit"
  "ripgrep"
  "fzf"
  "bat"
  "eza"
];
```

Then apply:
```bash
./scripts/apply-config "Added user packages"
```

Verify:
```bash
which neovim
neovim --version
```

### Add System Packages

Packages available system-wide:

```nix
systemSettings.packages.system.extra = [
  "htop"
  "git"
  "curl"
  "wget"
  "jq"
];
```

### Find Package Names

Search at: https://search.nixos.org

Or in terminal:
```bash
nix search nixpkgs neovim
```

## Adding SSH Keys

Add additional SSH keys for admin access:

```nix
systemSettings.sshKeys = [
  "ssh-ed25519 AAAAC3... user@laptop"
  "ssh-ed25519 AAAAC3... user@desktop"
  "ssh-ed25519 AAAAC3... user@server"
];
```

Get your key:
```bash
cat ~/.ssh/id_ed25519.pub
```

Then apply:
```bash
./scripts/apply-config "Added SSH keys"
```

Verify:
```bash
ssh xoa@YOUR-IP
```

## Enabling Storage

### Enable NFS

```nix
systemSettings.storage.nfs.enable = true;
```

Then apply:
```bash
./scripts/apply-config "Enabled NFS storage"
```

In XO web interface:
1. Go to Settings → Storage
2. Add NFS mount
3. Point to your NFS server

### Enable CIFS/SMB

```nix
systemSettings.storage.cifs.enable = true;
```

### Enable VHD Support

```nix
systemSettings.storage.vhd.enable = true;
```

### All Storage Backends

```nix
systemSettings.storage = {
  nfs.enable = true;
  cifs.enable = true;
  vhd.enable = true;
  mountsDir = "/var/lib/xo/mounts";
};
```

## Enabling Terminal Extras

Add enhanced shell and developer tools:

```nix
userSettings.extras.enable = true;
```

This adds:
- Zsh shell with Oh My Zsh
- Oh My Posh prompt (Darcula theme)
- Tools: fzf, ripgrep, fd, bat, eza
- Developer utilities: lazygit, gh, bottom, bandwhich
- Productivity: zoxide, direnv, broot, duf, dust

Apply:
```bash
./scripts/apply-config "Enabled terminal extras"
```

After applying, restart your shell or log out and back in.

## Changing Hostname

Change your system hostname:

```nix
systemSettings.hostname = "my-new-hostname";
```

Apply:
```bash
./scripts/apply-config "Changed hostname to my-new-hostname"
```

Verify:
```bash
hostname
```

## Changing XO Ports

### Change HTTP/HTTPS Ports

Default is 80 (HTTP) and 443 (HTTPS). Change if needed:

```nix
systemSettings.xo = {
  port = 8080;       # Custom HTTP port
  httpsPort = 8443;  # Custom HTTPS port
  tls.enable = true;
};
```

Then apply:
```bash
./scripts/apply-config "Changed XO ports to 8080/8443"
```

And update firewall:
```nix
systemSettings.networking.firewall.allowedTCPPorts = [
  22 8080 8443
];
```

## Firewall Configuration

### Open Additional Ports

```nix
systemSettings.networking.firewall.allowedTCPPorts = [
  22      # SSH (required)
  80      # HTTP (for XO)
  443     # HTTPS (for XO)
  3389    # RDP (optional)
  5900    # VNC (optional)
  8080    # Custom service
];
```

### Common Ports

- **22** - SSH (admin access)
- **80** - HTTP
- **443** - HTTPS
- **3389** - RDP (Remote Desktop)
- **5900** - VNC (Remote Desktop)
- **8012** - Custom services

Apply:
```bash
./scripts/apply-config "Opened additional firewall ports"
```

## Changing Boot Loader

### Use systemd-boot (Modern, Default)

```nix
systemSettings.boot.loader = "systemd-boot";
```

### Use GRUB (Legacy)

For older systems:

```nix
systemSettings.boot.loader = "grub";
```

Apply:
```bash
./scripts/apply-config "Changed boot loader to grub"
```

## Changing Timezone

```nix
systemSettings.timezone = "America/New_York";
```

Common examples:
- `UTC`
- `America/New_York`
- `America/Los_Angeles`
- `Europe/London`
- `Europe/Paris`
- `Asia/Tokyo`
- `Australia/Sydney`

Full list: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

Apply:
```bash
./scripts/apply-config "Changed timezone to America/New_York"
```

Verify:
```bash
date
timedatectl
```

## Enabling Automated Updates

### NixPkgs Updates

Automatically update packages:

```nix
systemSettings.updates.nixpkgs = {
  enable = true;
  schedule = "Mon 04:00";
  keepGenerations = 7;
};
```

### Xen Orchestra Updates

Automatically update XO:

```nix
systemSettings.updates.xoa = {
  enable = true;
  schedule = "Tue 04:00";
  keepGenerations = 7;
};
```

Apply:
```bash
./scripts/apply-config "Enabled automated updates"
```

Check timers:
```bash
systemctl list-timers | grep xoa
```

## Using Your Own TLS Certificates

If you have your own SSL certificates:

```nix
systemSettings.xo.tls = {
  enable = true;
  autoGenerate = false;  # Don't auto-generate
};
```

Then manually place certificates:

```bash
sudo cp your-cert.pem /etc/ssl/xo/certificate.pem
sudo cp your-key.pem /etc/ssl/xo/key.pem
sudo chown xo:xo /etc/ssl/xo/*.pem
sudo chmod 640 /etc/ssl/xo/*.pem
sudo systemctl restart xo-server.service
```

## Custom Services

Enable additional NixOS services:

For Docker:
```nix
systemSettings.services.docker.enable = true;
```

For Tailscale:
```nix
systemSettings.services.tailscale.enable = true;
```

Then apply:
```bash
./scripts/apply-config "Enabled Docker"
```

## Network Configuration

### Static IP Address

In `modules/home.nix` or in system configuration:

```nix
networking.interfaces.eth0.ipv4.addresses = [
  { address = "192.168.1.100"; prefixLength = 24; }
];
networking.defaultGateway = "192.168.1.1";
```

### DNS Settings

```nix
networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
```

## Reducing Nix Store Size

If disk is full:

```bash
# Remove unused packages
sudo nix-collect-garbage

# Remove old generations too (more aggressive)
sudo nix-collect-garbage -d

# Check store size
du -sh /nix/store
```

## Tips

### Validate Before Applying

```bash
cd ~/user-config
nix flake check .
```

### See What Would Change

```bash
sudo nixos-rebuild dry-run --flake .#HOSTNAME
```

### Test Without Switching Boot

```bash
sudo nixos-rebuild test --flake .#HOSTNAME
```

Changes apply but won't persist after reboot.

### Rollback If Something Breaks

```bash
sudo nixos-rebuild switch --rollback
```

### View Available Configuration Options

For complete option reference:

```bash
man configuration.nix
nix search nixpkgs
```

Or see nixoa-vm documentation:

```bash
cat /etc/nixos/nixoa-vm/CONFIGURATION.md
```

## See Also

- [Configuration Guide](./configuration.md) - All configuration options
- [Daily Workflow](./workflow.md) - How to apply changes
- [Troubleshooting](./troubleshooting.md) - Fix problems
