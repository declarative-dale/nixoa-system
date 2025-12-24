#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Commit configuration changes to the local git repository

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

cd "$CONFIG_DIR"

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "Error: Not a git repository. Initializing..."
    git init
    git add .
    git commit -m "Initial commit"
    echo "Git repository initialized."
fi

# Get commit message from argument or prompt
if [ $# -eq 0 ]; then
    echo "Usage: $0 <commit message>"
    echo "Example: $0 'Updated XO ports and TLS settings'"
    exit 1
fi

COMMIT_MSG="$1"

# Show what's changed
echo "=== Configuration Changes ==="
git diff --stat configuration.nix config.nixoa.toml 2>/dev/null || true
echo ""

# Check if there are changes to commit
if git diff --quiet configuration.nix config.nixoa.toml 2>/dev/null; then
    echo "No changes to commit."
    exit 0
fi

# Commit the changes (auto-stages tracked files)
git commit -a -m "$COMMIT_MSG"

echo "✓ Configuration committed successfully!"
echo ""
echo "Next steps:"
echo "  1. Review changes: git log -1 -p"
# Get configured hostname for rebuild command
CONFIG_HOST=$(grep "hostname = " configuration.nix 2>/dev/null | sed 's/.*= *"\(.*\)".*/\1/' | head -1)
CONFIG_HOST="${CONFIG_HOST:-nixoa}"
echo "  2. Rebuild NiXOA: cd ~/user-config && sudo nixos-rebuild switch --flake .#${CONFIG_HOST}"
echo ""
echo "To undo this commit: git reset HEAD~1"
