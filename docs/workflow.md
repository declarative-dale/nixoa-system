# Daily Workflow

How to make changes to your configuration and apply them.

## Overview

The basic workflow is:

```
1. Edit configuration.nix
   ↓
2. Review changes (optional)
   ↓
3. Apply changes (commit + rebuild)
   ↓
4. Verify it worked
```

## Editing Your Configuration

### Open the File

```bash
cd ~/user-config
nano configuration.nix
```

Or use your favorite editor:
```bash
vim configuration.nix
code configuration.nix
```

### Make Changes

For example, to add a package:

```nix
userSettings.packages.extra = [
  "neovim"     # ← Add this line
];
```

Or to change a setting:

```nix
systemSettings = {
  hostname = "my-new-hostname";  # ← Changed
  # ... rest ...
};
```

### Save

When done editing, save the file (e.g., `Ctrl+O` in nano, `Ctrl+X` to exit).

## Review Changes (Optional)

Before applying, see what changed:

```bash
cd ~/user-config
./scripts/show-diff
```

Output shows:
- Modified files
- Added lines (green)
- Removed lines (red)

### Git Diff

Or use git directly:

```bash
git diff
```

More detailed:
```bash
git diff --stat          # Summary
git diff configuration.nix  # Just this file
```

## Apply Changes

Apply changes (commit + rebuild):

```bash
cd ~/user-config
./scripts/apply-config "Description of changes"
```

Replace `"Description of changes"` with what you changed. Examples:
- `"Added neovim package"`
- `"Enabled NFS storage"`
- `"Changed hostname to my-xoa"`
- `"Added SSH key"`

### What Happens

1. Validates configuration syntax
2. Commits your changes to git
3. Rebuilds NixOS system
4. Switches to new generation
5. Restarts affected services

**First rebuild takes 5-15 minutes. Subsequent rebuilds are faster.**

## Just Commit (Without Rebuilding)

If you want to commit without rebuilding:

```bash
cd ~/user-config
./scripts/commit-config "Description"

# Later, rebuild manually
sudo nixos-rebuild switch --flake .#HOSTNAME
```

## Just Rebuild (From Committed Code)

If code is already committed, just rebuild:

```bash
cd ~/user-config
sudo nixos-rebuild switch --flake .#HOSTNAME -L
```

The `-L` flag shows detailed logs.

## Check What's Committed

### View Recent Commits

```bash
cd ~/user-config
./scripts/history

# Or use git directly
git log --oneline -10
```

### See Details of a Commit

```bash
git show <commit-hash>
# Example: git show abc1234
```

### See All Changes Since Last Commit

```bash
git status        # Which files changed
git diff          # What changed
```

## Monitor Rebuild Progress

In another terminal, watch the build:

```bash
# Live logs
journalctl -f

# Or just XO logs
sudo journalctl -u xo-server -f
```

## Verify Changes Took Effect

After rebuild completes:

```bash
# Check hostname changed
hostname

# Check service is running
sudo systemctl status xo-server.service

# Check new packages installed (if added)
which neovim

# View logs
sudo journalctl -u xo-server -n 30
```

## Undoing Changes

### Undo Last Commit (Before Rebuilding)

```bash
cd ~/user-config
git reset HEAD~1
git diff          # See what you're reverting
git checkout -- .  # Discard all changes
```

### Rollback After Rebuild (System Won't Start)

```bash
# Go back to previous system generation
sudo nixos-rebuild switch --rollback

# Then revert your config changes
cd ~/user-config
git reset HEAD~1
git checkout -- configuration.nix
```

### Go Back to Older Configuration

```bash
cd ~/user-config
git log --oneline    # Find the commit hash
git reset <hash>     # Reset to that commit
git checkout -- .    # Discard any edits
```

## Common Workflows

### Add a Package

1. Edit:
```bash
nano ~/user-config/configuration.nix
# Add to userSettings.packages.extra = [ "neovim" ];
```

2. Apply:
```bash
./scripts/apply-config "Added neovim package"
```

3. Verify:
```bash
which neovim
```

### Change Hostname

1. Edit:
```bash
nano ~/user-config/configuration.nix
# Change: hostname = "new-hostname";
```

2. Apply:
```bash
./scripts/apply-config "Changed hostname to new-hostname"
```

3. Verify:
```bash
hostname
```

### Enable a Feature

1. Edit:
```bash
nano ~/user-config/configuration.nix
# Change: userSettings.extras.enable = true;
# OR: storage.nfs.enable = true;
```

2. Apply:
```bash
./scripts/apply-config "Enabled terminal extras"
# OR: ./scripts/apply-config "Enabled NFS storage"
```

3. Verify (depends on feature)

### Add Multiple Changes

You can make multiple edits before applying:

```bash
# Edit file
nano configuration.nix
# ... make several changes ...

# Edit again
nano configuration.nix
# ... make more changes ...

# Apply all at once
./scripts/apply-config "Multiple improvements"
```

## Checking Configuration Status

### See Uncommitted Changes

```bash
./scripts/show-diff
# or
git status
git diff
```

### See Commit History

```bash
./scripts/history
# or
git log --oneline -15
```

### See Specific Commit Details

```bash
git show <commit-hash>
git show HEAD        # Latest commit
git show HEAD~1      # Commit before latest
```

## Tips & Tricks

### Dry Run (See What Would Change)

Build without switching:

```bash
sudo nixos-rebuild test --flake .#HOSTNAME
```

Or preview without building:

```bash
sudo nixos-rebuild dry-run --flake .#HOSTNAME
```

### Verbose Output

See detailed build logs:

```bash
sudo nixos-rebuild switch --flake .#HOSTNAME -L -v
```

### Search for Package Name

```bash
nix search nixpkgs neovim
# Shows all matches with descriptions
```

### Validate Before Applying

```bash
cd ~/user-config
nix flake check .
```

No output = valid. Errors shown = fix them.

## Troubleshooting Workflow

### Rebuild Failed

```bash
# See error
sudo journalctl -xe

# Full rebuild log
sudo nixos-rebuild switch --flake .#HOSTNAME -L
```

### Configuration Won't Apply

```bash
# Check syntax
nix flake check .

# Check git status
git status

# Maybe unstaged changes?
git add .
git commit -m "Fix"
```

### Lost Changes

```bash
# Git history
git log --oneline --all

# Recover
git reset <hash>
```

## See Also

- [Configuration Guide](./configuration.md) - What settings are available
- [Common Tasks](./common-tasks.md) - Configuration examples
- [Troubleshooting](./troubleshooting.md) - Fix problems
- [How It Works](./how-it-works.md) - How the system works
