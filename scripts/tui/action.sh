#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib.sh"

nixoa_require_git_repo
nixoa_cd_root

usage() {
  cat <<'EOF'
Usage: action.sh <command> [value]

Commands:
  set-hostname VALUE
  set-username VALUE
  set-ssh-key VALUE
  add-ssh-key VALUE
  remove-ssh-key VALUE
  toggle-extras
  add-system-package VALUE
  add-user-package VALUE
  add-service VALUE
  update-rebuild
EOF
}

load_state() {
  hostname_value="$(nixoa_tui_hostname)"
  username_value="$(nixoa_tui_username)"
  timezone_value="$(nixoa_tui_timezone)"
  extras_value="$(nixoa_tui_enable_extras)"

  mapfile -t ssh_keys_value < <(nixoa_tui_ssh_keys)
  mapfile -t system_packages_value < <(nixoa_tui_extra_system_packages)
  mapfile -t user_packages_value < <(nixoa_tui_extra_user_packages)
  mapfile -t services_value < <(nixoa_tui_enabled_services)
}

if [ $# -lt 1 ]; then
  usage >&2
  exit 1
fi

command_name="$1"
shift

load_state

case "$command_name" in
  set-hostname)
    [ $# -eq 1 ] || { usage >&2; exit 1; }
    nixoa_tui_validate_token "hostname" "$1"
    hostname_value="$1"
    nixoa_tui_write_menu \
      "$hostname_value" \
      "$username_value" \
      "$timezone_value" \
      "$extras_value" \
      ssh_keys_value \
      system_packages_value \
      user_packages_value \
      services_value
    nixoa_tui_commit_paths "Set hostname to ${hostname_value} from nixoa-menu" config/menu.nix
    ;;
  set-username)
    [ $# -eq 1 ] || { usage >&2; exit 1; }
    nixoa_tui_validate_token "username" "$1"
    username_value="$1"
    nixoa_tui_write_menu \
      "$hostname_value" \
      "$username_value" \
      "$timezone_value" \
      "$extras_value" \
      ssh_keys_value \
      system_packages_value \
      user_packages_value \
      services_value
    nixoa_tui_commit_paths "Set username to ${username_value} from nixoa-menu" config/menu.nix
    ;;
  set-ssh-key)
    [ $# -eq 1 ] || { usage >&2; exit 1; }
    nixoa_tui_validate_ssh_key "$1"
    ssh_keys_value=("$1")
    nixoa_tui_write_menu \
      "$hostname_value" \
      "$username_value" \
      "$timezone_value" \
      "$extras_value" \
      ssh_keys_value \
      system_packages_value \
      user_packages_value \
      services_value
    nixoa_tui_commit_paths "Set SSH key from nixoa-menu" config/menu.nix
    ;;
  add-ssh-key)
    [ $# -eq 1 ] || { usage >&2; exit 1; }
    nixoa_tui_validate_ssh_key "$1"
    if nixoa_tui_append_unique "$1" ssh_keys_value; then
      nixoa_tui_write_menu \
        "$hostname_value" \
        "$username_value" \
        "$timezone_value" \
        "$extras_value" \
        ssh_keys_value \
        system_packages_value \
        user_packages_value \
        services_value
      nixoa_tui_commit_paths "Add SSH key from nixoa-menu" config/menu.nix
    else
      echo "SSH key already present."
    fi
    ;;
  remove-ssh-key)
    [ $# -eq 1 ] || { usage >&2; exit 1; }
    if nixoa_tui_remove_value "$1" ssh_keys_value; then
      if [ "${#ssh_keys_value[@]}" -eq 0 ]; then
        echo "At least one SSH key is required." >&2
        exit 1
      fi
      nixoa_tui_write_menu \
        "$hostname_value" \
        "$username_value" \
        "$timezone_value" \
        "$extras_value" \
        ssh_keys_value \
        system_packages_value \
        user_packages_value \
        services_value
      nixoa_tui_commit_paths "Remove SSH key from nixoa-menu" config/menu.nix
    else
      echo "SSH key not found."
    fi
    ;;
  toggle-extras)
    if [ "$extras_value" = "true" ]; then
      extras_value="false"
      commit_message="Disable extras from nixoa-menu"
    else
      extras_value="true"
      commit_message="Enable extras from nixoa-menu"
    fi
    nixoa_tui_write_menu \
      "$hostname_value" \
      "$username_value" \
      "$timezone_value" \
      "$extras_value" \
      ssh_keys_value \
      system_packages_value \
      user_packages_value \
      services_value
    nixoa_tui_commit_paths "$commit_message" config/menu.nix
    ;;
  add-system-package)
    [ $# -eq 1 ] || { usage >&2; exit 1; }
    nixoa_tui_validate_token "package" "$1"
    if nixoa_tui_append_unique "$1" system_packages_value; then
      nixoa_tui_write_menu \
        "$hostname_value" \
        "$username_value" \
        "$timezone_value" \
        "$extras_value" \
        ssh_keys_value \
        system_packages_value \
        user_packages_value \
        services_value
      nixoa_tui_commit_paths "Add system package ${1} from nixoa-menu" config/menu.nix
    else
      echo "System package already present."
    fi
    ;;
  add-user-package)
    [ $# -eq 1 ] || { usage >&2; exit 1; }
    nixoa_tui_validate_token "package" "$1"
    if nixoa_tui_append_unique "$1" user_packages_value; then
      nixoa_tui_write_menu \
        "$hostname_value" \
        "$username_value" \
        "$timezone_value" \
        "$extras_value" \
        ssh_keys_value \
        system_packages_value \
        user_packages_value \
        services_value
      nixoa_tui_commit_paths "Add user package ${1} from nixoa-menu" config/menu.nix
    else
      echo "User package already present."
    fi
    ;;
  add-service)
    [ $# -eq 1 ] || { usage >&2; exit 1; }
    nixoa_tui_validate_token "service" "$1"
    if nixoa_tui_append_unique "$1" services_value; then
      nixoa_tui_write_menu \
        "$hostname_value" \
        "$username_value" \
        "$timezone_value" \
        "$extras_value" \
        ssh_keys_value \
        system_packages_value \
        user_packages_value \
        services_value
      nixoa_tui_commit_paths "Enable service ${1} from nixoa-menu" config/menu.nix
    else
      echo "Service already present."
    fi
    ;;
  update-rebuild)
    nix flake update
    nixoa_tui_commit_paths "Update flake inputs from nixoa-menu" flake.lock
    "$NIXOA_SYSTEM_ROOT/scripts/apply-config.sh"
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
