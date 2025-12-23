#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Show uncommitted configuration changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

cd "$CONFIG_DIR"

if [ ! -d .git ]; then
    echo "Error: Not a git repository."
    exit 1
fi

echo "=== Uncommitted Changes ==="
git diff configuration.nix config.nixoa.toml

if git diff --quiet configuration.nix config.nixoa.toml; then
    echo "No uncommitted changes."
fi
