#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Commit and apply configuration changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
IDENTITY_FILE="${CONFIG_DIR}/config/host.nix"

# Get commit message from argument or use default
if [ $# -eq 0 ]; then
    COMMIT_MSG="Update configuration [$(date '+%Y-%m-%d %H:%M:%S')]"
else
    COMMIT_MSG="$1"
fi

# Commit the configuration
echo "=== Committing configuration changes ==="
"$SCRIPT_DIR/commit-config.sh" "$COMMIT_MSG"

# Apply the configuration from system directory
echo ""
echo "=== Applying configuration to NiXOA ==="
cd "$CONFIG_DIR"

# Read hostname from config/host.nix
HOSTNAME=$(grep "hostname = " "$IDENTITY_FILE" 2>/dev/null | head -1 | sed 's/.*hostname = *"\(.*\)".*/\1/')
HOSTNAME="${HOSTNAME:-nixoa}"

echo "Building configuration for hostname: ${HOSTNAME}"
echo "Note: Use nixos-rebuild directly to apply the configuration"
echo "Run: sudo nixos-rebuild switch --flake .#${HOSTNAME}"

echo ""
echo "✓ Configuration applied successfully!"
