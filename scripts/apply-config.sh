#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Commit and apply configuration changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# Get commit message from argument or use default
if [ $# -eq 0 ]; then
    COMMIT_MSG="Update configuration [$(date '+%Y-%m-%d %H:%M:%S')]"
else
    COMMIT_MSG="$1"
fi

# Commit the configuration
echo "=== Committing configuration changes ==="
"$SCRIPT_DIR/commit-config.sh" "$COMMIT_MSG"

# Apply the configuration
echo ""
echo "=== Applying configuration to NiXOA ==="
cd /etc/nixos/nixoa/nixoa-vm

# Read hostname from user-config (defaults to "nixoa" if not set)
HOSTNAME=$(grep "^hostname" "${CONFIG_DIR}/system-settings.toml" 2>/dev/null | sed 's/.*= *"\(.*\)".*/\1/' | head -1)
HOSTNAME="${HOSTNAME:-nixoa}"

echo "Running: sudo nixos-rebuild switch --flake .#${HOSTNAME}"
sudo nixos-rebuild switch --flake ".#${HOSTNAME}"

echo ""
echo "✓ Configuration applied successfully!"
