# Troubleshooting Guide

Solutions for common user-config problems.

## Syntax Errors

**Error:** `error: unexpected ... expected ...`

**Cause:** Nix syntax error in configuration.nix

**Check:**
```bash
cd ~/user-config
nix flake check .
```

**Common mistakes:**

Missing semicolon:
```nix
hostname = "my-xoa"  # ✗ Wrong
hostname = "my-xoa"; # ✓ Correct
```

Unclosed brackets:
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

Wrong quotes:
```nix
hostname = 'my-xoa';   # ✗ Single quotes
hostname = "my-xoa";   # ✓ Double quotes
```

### Fix It

1. Check `nix flake check .` output for line number
2. Open `configuration.nix` at that line
3. Look for missing `;` `:` `]` `}`
4. Fix and try again

## Package Not Found

**Error:** `attribute 'packagename' missing`

**Cause:** Wrong package name in configuration

**Example:**
```nix
packages.extra = [
  "nvim"  # ✗ Wrong name
];
```

**Fix:**

Search for correct name:
```bash
nix search nixpkgs neovim
```

Output shows correct name: `neovim`

```nix
packages.extra = [
  "neovim"  # ✓ Correct
];
```

## Rebuild Failed

**Error:** Build fails or hangs

**Check logs:**
```bash
sudo journalctl -xe
```

**Common causes:**

### Out of Disk Space

```bash
df -h
```

### Network Timeout

Downloading packages failed. Try again:
```bash
sudo nixos-rebuild switch --flake .#HOSTNAME
```

Or use different mirror (in flake.nix if needed).

### Memory Issues

If system becomes unresponsive:
```bash
# Kill rebuild to free memory
sudo pkill -f nixos-rebuild

# Add swap or increase VM memory
free -h
```

Then try again with smaller changes.

## Changes Not Applied

**Problem:** Configuration changed but rebuild succeeded, but changes don't take effect

**Cause:** Service didn't restart or wrong setting

**Check:**

1. Did you actually run `apply-config`?
   ```bash
   git log --oneline | head
   # Should show your commit
   ```

2. Is the service running?
   ```bash
   sudo systemctl status xo-server.service
   ```

3. Is the setting actually in use?
   ```bash
   # Check what's being used
   cat /etc/xo-server/config.nixoa.toml
   ```

**Fix:**

Restart the affected service:
```bash
sudo systemctl restart xo-server.service
```

Or full rebuild:
```bash
./scripts/apply-config "Rebuild to apply changes"
```

## SSH Keys Not Working

**Problem:** Can't SSH to system after adding keys

**Cause:** Keys not added correctly or file permissions wrong

**Check:**

1. Are keys in authorized_keys?
   ```bash
   sudo cat /home/xoa/.ssh/authorized_keys
   # Should show your public key
   ```

2. Is key in your configuration?
   ```bash
   cat ~/user-config/configuration.nix | grep -A 2 sshKeys
   # Should show your key
   ```

3. Did you apply changes?
   ```bash
   git log --oneline | head
   # Should show your commit
   ```

**Fix:**

1. Get your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

2. Add to configuration:
   ```bash
   nano ~/user-config/configuration.nix
   # Update systemSettings.sshKeys
   ```

3. Apply:
   ```bash
   ./scripts/apply-config "Added SSH key"
   ```

4. Wait for rebuild, then try:
   ```bash
   ssh xoa@YOUR-IP
   ```

## Git Issues

### Git Not Initialized

**Error:** `not a git repository`

**Fix:**

```bash
cd ~/user-config
git init
git add .
git commit -m "Initial commit"
```

### Can't Commit

**Error:** Git errors when running `apply-config`

**Check:**

```bash
cd ~/user-config
git status
git config user.name
git config user.email
```

**Fix:**

Configure git:
```bash
git config user.name "Your Name"
git config user.email "your@email.com"
git config --global user.name "Your Name"  # All repositories
git config --global user.email "your@email.com"
```

Then try again:
```bash
./scripts/apply-config "Description"
```

### File Permissions on Scripts

**Error:** `Permission denied` when running scripts

**Fix:**

```bash
chmod +x ~/user-config/scripts/*.sh
chmod +x ~/user-config/commit-config
chmod +x ~/user-config/apply-config
chmod +x ~/user-config/show-diff
chmod +x ~/user-config/history
```

## Configuration Validation

### Dry Run (See What Would Change)

Build without applying:
```bash
sudo nixos-rebuild dry-run --flake .#HOSTNAME
```

### Test Mode (Apply But Don't Boot)

Apply changes without setting as boot default:
```bash
sudo nixos-rebuild test --flake .#HOSTNAME
```

Changes take effect but don't persist after reboot.

## Rolling Back

### Undo Last Commit

If you committed something wrong:

```bash
cd ~/user-config
git reset HEAD~1
git diff              # See what you're undoing
git checkout -- .     # Discard all changes
```

### Rollback System

If system doesn't boot after rebuild:

```bash
# Boot to previous generation
sudo nixos-rebuild switch --rollback

# Then undo your config change
cd ~/user-config
git reset HEAD~1
git checkout -- configuration.nix
```

### Go Back to Older Configuration

```bash
cd ~/user-config
git log --oneline        # Find the good commit
git reset <commit-hash>  # Reset to that point
git checkout -- .        # Discard edits
```

## Hostname Won't Change

**Problem:** Changed hostname but it didn't take effect

**Check:**

```bash
hostname
hostnamectl status
```

**Fix:**

Make sure you ran `apply-config`:
```bash
git log --oneline | head
# Should show your hostname commit
```

If committed but system shows old hostname, rebuild fully:
```bash
sudo nixos-rebuild switch --flake .#HOSTNAME --recreate-lock-file
hostname  # Check it changed
```

## Firewall Issues

### Port Not Opening

**Problem:** Service listening but can't access from remote

**Check:**

```bash
# Is service listening?
sudo ss -tlnp | grep 80
sudo ss -tlnp | grep 443

# Is port in firewall config?
cat ~/user-config/configuration.nix | grep allowedTCPPorts

# Did you apply changes?
git log --oneline | head
```

**Fix:**

1. Add port to configuration:
   ```nix
   systemSettings.networking.firewall.allowedTCPPorts = [
     22 80 443 8080  # Add your port
   ];
   ```

2. Apply:
   ```bash
   ./scripts/apply-config "Opened firewall port 8080"
   ```

3. Verify:
   ```bash
   sudo ss -tlnp | grep 8080
   ```

## Storage Mount Not Working

**Problem:** Storage enabled but mounts not showing in XO

**Check:**

1. Is storage enabled?
   ```bash
   cat ~/user-config/configuration.nix | grep storage
   ```

2. Did you apply changes?
   ```bash
   git log --oneline | head
   ```

3. Is mount directory accessible?
   ```bash
   ls -la /var/lib/xo/mounts/
   ```

**Fix:**

1. Enable storage:
   ```nix
   systemSettings.storage.nfs.enable = true;
   ```

2. Apply:
   ```bash
   ./scripts/apply-config "Enabled NFS"
   ```

3. In XO web interface: Settings → Storage → Add

## Performance Issues

### Slow Rebuild

**Cause:** Building from scratch takes time

First rebuild: 5-15 minutes (normal)
Subsequent: 1-5 minutes (normal)

**If much slower:**
- Check disk I/O: `iostat -x 1`
- Check memory: `free -h`
- Check network: `ping 8.8.8.8`

### System Slow After Changes

**Check:**

```bash
# Memory usage
free -h
top

# Disk usage
df -h
du -sh /nix/store

# CPU usage
top
```

**Fix:**

```bash
# Restart services
sudo systemctl restart xo-server.service
```

## Lost Changes

### Unstaged Changes

Changed file but didn't commit:

```bash
cd ~/user-config
git status              # See changed files
git diff configuration.nix  # See changes
git add .
git commit -m "Description"
./scripts/apply-config "Reapply changes"
```

### Lost Commits

Accidentally reset? Git keeps history:

```bash
git reflog                    # See all changes
git reset <old-hash>          # Go back to that commit
git reset --hard <old-hash>   # Revert completely
```

## Getting More Help

### Debug Logs

```bash
# Full system logs
sudo journalctl -b

# XO-specific
sudo journalctl -u xo-server -n 100

# Rebuild logs
sudo nixos-rebuild switch --flake .#HOSTNAME -L -v
```

### Configuration Check

```bash
# Validate syntax
nix flake check .

# Show evaluated config
nix eval .#nixosConfigurations.<hostname>.config.nixoa
```

### Check Git Status

```bash
cd ~/user-config
git status              # Uncommitted changes
git log --oneline -10   # Recent commits
git remote -v           # Remote repositories
```

## See Also

- [Daily Workflow](./workflow.md) - Making changes
- [Configuration Guide](./configuration.md) - Configuration options
- [Common Tasks](./common-tasks.md) - Configuration examples
