#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

readonly NIXOA_SYSTEM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly NIXOA_DEFAULT_HOSTNAME="nixoa"
readonly NIXOA_DEFAULT_USERNAME="nixoa"
readonly NIXOA_DEFAULT_TIMEZONE="Europe/Paris"
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

nixoa_config_string() {
  local key="$1"
  local file
  local value

  for file in \
    "$NIXOA_SYSTEM_ROOT/config/overrides.nix" \
    "$NIXOA_SYSTEM_ROOT/config/site.nix"
  do
    [ -f "$file" ] || continue
    value="$(sed -nE "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*\"([^\"]*)\"[[:space:]]*;.*$/\\1/p" "$file" | tail -n 1)"
    if [ -n "$value" ]; then
      printf '%s\n' "$value"
      return 0
    fi
  done

  return 1
}

nixoa_default_hostname() {
  nixoa_config_string hostname || printf '%s\n' "$NIXOA_DEFAULT_HOSTNAME"
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
