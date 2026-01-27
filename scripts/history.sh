#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Show configuration change history

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILES=(configuration.nix config config.nixoa.toml)

cd "$CONFIG_DIR"

if [ ! -d .git ]; then
    echo "Error: Not a git repository."
    exit 1
fi

echo "=== Configuration Change History ==="
git log --oneline --decorate --graph -10 -- "${CONFIG_FILES[@]}"

echo ""
echo "To see full diff for a commit: git show <commit-hash>"
echo "To revert to a previous commit: git checkout <commit-hash> -- ${CONFIG_FILES[*]}"
