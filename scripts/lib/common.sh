#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

readonly NIXOA_SYSTEM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly NIXOA_DEFAULT_HOSTNAME="nixoa"
readonly NIXOA_DEFAULT_USERNAME="nixoa"
readonly NIXOA_DEFAULT_TIMEZONE="Europe/Paris"
readonly NIXOA_MENU_FILE="$NIXOA_SYSTEM_ROOT/config/menu.nix"
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

nixoa_state_dir() {
  printf '%s\n' "${NIXOA_STATE_DIR:-${XDG_STATE_HOME:-${HOME:-$NIXOA_SYSTEM_ROOT/.local/state}}/nixoa}"
}

nixoa_apply_state_file() {
  printf '%s\n' "${NIXOA_STATUS_FILE:-$(nixoa_state_dir)/apply-state.env}"
}

nixoa_rebuild_queue_file() {
  printf '%s\n' "${NIXOA_REBUILD_QUEUE_FILE:-/var/lib/nixoa/rebuild-on-boot.env}"
}

nixoa_config_string() {
  local key="$1"
  local file
  local value

  for file in \
    "$NIXOA_MENU_FILE" \
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

nixoa_write_apply_state() {
  local result="$1"
  local action="$2"
  local hostname="$3"
  local head="$4"
  local first_install="$5"
  local exit_code="$6"
  local state_file
  local state_dir

  state_file="$(nixoa_apply_state_file)"
  state_dir="$(dirname "$state_file")"
  mkdir -p "$state_dir"

  {
    printf 'last_apply_result=%s\n' "$result"
    printf 'last_apply_action=%s\n' "$action"
    printf 'last_apply_hostname=%s\n' "$hostname"
    printf 'last_apply_head=%s\n' "$head"
    printf 'last_apply_first_install=%s\n' "$first_install"
    printf 'last_apply_exit_code=%s\n' "$exit_code"
    printf 'last_apply_timestamp=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$state_file"
}

nixoa_schedule_rebuild_on_boot() {
  local repo_root="$1"
  local hostname="$2"
  local queue_file
  local queue_dir

  queue_file="$(nixoa_rebuild_queue_file)"
  queue_dir="$(dirname "$queue_file")"

  if [ "$(id -u)" -eq 0 ]; then
    install -d -m 0755 "$queue_dir"
    {
      printf 'repo_root=%q\n' "$repo_root"
      printf 'hostname=%q\n' "$hostname"
      printf 'scheduled_at=%q\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    } > "$queue_file"
    return 0
  fi

  sudo install -d -m 0755 "$queue_dir"
  {
    printf 'repo_root=%q\n' "$repo_root"
    printf 'hostname=%q\n' "$hostname"
    printf 'scheduled_at=%q\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } | sudo tee "$queue_file" >/dev/null
}
