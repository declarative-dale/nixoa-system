#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

readonly NIXOA_SYSTEM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly NIXOA_DEFAULT_HOSTNAME="nixoa"
readonly NIXOA_DEFAULT_USERNAME="nixoa"
readonly NIXOA_DEFAULT_TIMEZONE="Europe/Paris"
readonly NIXOA_DEFAULT_GIT_NAME="NiXOA Admin"
readonly NIXOA_DEFAULT_GIT_EMAIL="nixoa@nixoa"
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
  local default_state_home

  default_state_home="${XDG_STATE_HOME:-${HOME:-$NIXOA_SYSTEM_ROOT}/.local/state}"
  printf '%s\n' "${NIXOA_STATE_DIR:-$default_state_home/nixoa}"
}

nixoa_shared_state_dir() {
  printf '%s\n' "${NIXOA_SHARED_STATE_DIR:-/var/lib/nixoa}"
}

nixoa_apply_state_file() {
  printf '%s\n' "${NIXOA_STATUS_FILE:-$(nixoa_shared_state_dir)/apply-state.env}"
}

nixoa_legacy_apply_state_file() {
  printf '%s\n' "$(nixoa_state_dir)/apply-state.env"
}

nixoa_rebuild_queue_file() {
  printf '%s\n' "${NIXOA_REBUILD_QUEUE_FILE:-$(nixoa_shared_state_dir)/rebuild-on-boot.env}"
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

nixoa_git_user_name() {
  nixoa_config_string gitName || printf '%s\n' "$NIXOA_DEFAULT_GIT_NAME"
}

nixoa_git_user_email() {
  nixoa_config_string gitEmail || printf '%s\n' "$NIXOA_DEFAULT_GIT_EMAIL"
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

nixoa_has_changes() {
  [ -n "$(nixoa_status_porcelain)" ]
}

nixoa_stage_changes() {
  git -C "$NIXOA_SYSTEM_ROOT" add -A -- "${NIXOA_TRACKED_PATHS[@]}"
}

nixoa_has_staged_changes() {
  ! git -C "$NIXOA_SYSTEM_ROOT" diff --cached --quiet -- "${NIXOA_TRACKED_PATHS[@]}"
}

nixoa_print_change_summary() {
  echo "=== Configuration Changes ==="
  git -C "$NIXOA_SYSTEM_ROOT" diff HEAD --stat -- "${NIXOA_TRACKED_PATHS[@]}" 2>/dev/null || true

  if nixoa_has_changes; then
    echo ""
    nixoa_status_porcelain
  fi

  echo ""
}

nixoa_generate_commit_body() {
  local updated=()
  local added=()
  local removed=()
  local renamed=()
  local emitted=0
  local status=""
  local first=""
  local second=""

  while IFS=$'\t' read -r status first second; do
    [ -n "$status" ] || continue

    case "$status" in
      A*)
        added+=("$first")
        ;;
      D*)
        removed+=("$first")
        ;;
      R*)
        renamed+=("$first -> $second")
        ;;
      *)
        updated+=("$first")
        ;;
    esac
  done < <(git -C "$NIXOA_SYSTEM_ROOT" diff --cached --name-status --find-renames -- "${NIXOA_TRACKED_PATHS[@]}")

  if [ "${#updated[@]}" -gt 0 ]; then
    echo "Updated:"
    printf -- '- %s\n' "${updated[@]}"
    emitted=1
  fi

  if [ "${#added[@]}" -gt 0 ]; then
    [ "$emitted" -eq 1 ] && echo ""
    echo "Added:"
    printf -- '- %s\n' "${added[@]}"
    emitted=1
  fi

  if [ "${#removed[@]}" -gt 0 ]; then
    [ "$emitted" -eq 1 ] && echo ""
    echo "Removed:"
    printf -- '- %s\n' "${removed[@]}"
    emitted=1
  fi

  if [ "${#renamed[@]}" -gt 0 ]; then
    [ "$emitted" -eq 1 ] && echo ""
    echo "Renamed:"
    printf -- '- %s\n' "${renamed[@]}"
  fi
}

nixoa_commit_changes() {
  local commit_message="${1:-}"
  local subject="Record local system changes"
  local body=""
  local git_name=""
  local git_email=""
  local -a git_commit_cmd=()

  if [ -z "${commit_message//[[:space:]]/}" ] && [ -t 0 ]; then
    read -r -p "Commit message [auto]: " commit_message
  fi

  if [ -n "${commit_message//[[:space:]]/}" ]; then
    git_name="$(nixoa_git_user_name)"
    git_email="$(nixoa_git_user_email)"
    git_commit_cmd=(
      git
      -C "$NIXOA_SYSTEM_ROOT"
      -c "user.name=$git_name"
      -c "user.email=$git_email"
      commit
    )
    "${git_commit_cmd[@]}" -m "$commit_message"
    return 0
  fi

  body="$(nixoa_generate_commit_body)"
  git_name="$(nixoa_git_user_name)"
  git_email="$(nixoa_git_user_email)"
  git_commit_cmd=(
    git
    -C "$NIXOA_SYSTEM_ROOT"
    -c "user.name=$git_name"
    -c "user.email=$git_email"
    commit
  )
  if [ -n "$body" ]; then
    "${git_commit_cmd[@]}" -m "$subject" -m "$body"
  else
    "${git_commit_cmd[@]}" -m "$subject"
  fi
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
  local temp_file
  local first_install_bool="false"

  case "$first_install" in
    1|true|TRUE|yes|on)
      first_install_bool="true"
      ;;
  esac

  state_file="$(nixoa_apply_state_file)"
  state_dir="$(dirname "$state_file")"
  temp_file="$(mktemp)"

  {
    printf 'last_apply_result=%s\n' "$result"
    printf 'last_apply_action=%s\n' "$action"
    printf 'last_apply_hostname=%s\n' "$hostname"
    printf 'last_apply_head=%s\n' "$head"
    printf 'last_apply_first_install=%s\n' "$first_install_bool"
    printf 'last_apply_exit_code=%s\n' "$exit_code"
    printf 'last_apply_timestamp=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$temp_file"

  if [ "$(id -u)" -eq 0 ]; then
    install -d -m 0755 "$state_dir"
    install -m 0644 "$temp_file" "$state_file"
  else
    sudo install -d -m 0755 "$state_dir"
    sudo install -m 0644 "$temp_file" "$state_file"
  fi

  rm -f "$temp_file"
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
