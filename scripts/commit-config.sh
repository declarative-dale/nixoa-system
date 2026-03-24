#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Commit configuration changes to the local git repository

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
nixoa_require_git_repo
nixoa_cd_root

if [ $# -eq 0 ]; then
  echo "Usage: $0 <commit message>" >&2
  echo "Example: $0 'Adjust XO TLS and firewall defaults'" >&2
  exit 1
fi

COMMIT_MSG="$1"

echo "=== Configuration Changes ==="
git diff --stat -- "${NIXOA_TRACKED_PATHS[@]}" 2>/dev/null || true
if [ -n "$(nixoa_status_porcelain)" ]; then
  echo ""
  nixoa_status_porcelain
fi
echo ""

if [ -z "$(nixoa_status_porcelain)" ]; then
  echo "No changes to commit."
  exit 0
fi

git add -- "${NIXOA_TRACKED_PATHS[@]}"

git commit -m "$COMMIT_MSG"

echo "✓ Configuration committed successfully!"
echo ""
echo "Next steps:"
echo "  1. Review changes: git log -1 -p"
echo "  2. Apply the host config: ./scripts/apply-config.sh"
echo ""
echo "To undo this commit: git reset HEAD~1"
