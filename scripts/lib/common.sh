#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

readonly NIXOA_SYSTEM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly -a NIXOA_TRACKED_PATHS=(
  AGENTS.md
  README.md
  config
  config.nixoa.toml
  docs
  flake.lock
  flake.nix
  hardware-configuration.nix
  modules
  scripts
)

nixoa_system_root() {
  printf '%s\n' "$NIXOA_SYSTEM_ROOT"
}

nixoa_default_hostname() {
  hostname -s 2>/dev/null || printf '%s\n' "nixoa"
}

nixoa_cd_root() {
  cd "$NIXOA_SYSTEM_ROOT"
}

nixoa_require_git_repo() {
  if [ ! -d "$NIXOA_SYSTEM_ROOT/.git" ]; then
    echo "Error: $NIXOA_SYSTEM_ROOT is not a git repository." >&2
    exit 1
  fi
}

nixoa_status_porcelain() {
  git -C "$NIXOA_SYSTEM_ROOT" status --short -- "${NIXOA_TRACKED_PATHS[@]}"
}
