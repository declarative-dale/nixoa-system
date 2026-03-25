#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib.sh"

nixoa_require_git_repo
nixoa_cd_root
export NIXOA_SYSTEM_ROOT

prompt_default() {
  local label="$1"
  local default_value="$2"
  local reply=""

  read -r -p "$label [$default_value]: " reply
  printf '%s\n' "${reply:-$default_value}"
}

prompt_required() {
  local label="$1"
  local reply=""

  while [ -z "$reply" ]; do
    read -r -p "$label: " reply
  done

  printf '%s\n' "$reply"
}

pause() {
  printf '\n%s' "${1:-Press Enter to continue.}"
  read -r _
}

clear_screen() {
  printf '\033[2J\033[H'
}

run_action() {
  clear_screen
  "$SCRIPT_DIR/action.sh" "$@"
  pause
}

current_header() {
  mapfile -t ssh_keys < <(nixoa_tui_ssh_keys)
  mapfile -t system_packages < <(nixoa_tui_extra_system_packages)
  mapfile -t user_packages < <(nixoa_tui_extra_user_packages)
  mapfile -t services < <(nixoa_tui_enabled_services)

  cat <<EOF
============================================================
                    NiXOA System Console
============================================================
 Hostname: $(nixoa_tui_hostname)
 Username: $(nixoa_tui_username)
 Time Zone: $(nixoa_tui_timezone)
 Extras: $(nixoa_tui_enable_extras)
 SSH Keys: ${#ssh_keys[@]}
 System Packages: ${#system_packages[@]}
 User Packages: ${#user_packages[@]}
 Enabled Services: ${#services[@]}
 Pending Repo Changes: $(nixoa_tui_dirty_count)
============================================================
EOF
}

show_menu() {
  cat <<'EOF'
  1) Edit hostname
  2) Edit username
  3) Manage SSH keys
  4) Enable/disable extras
  5) Add system package
  6) Add user package
  7) Add service
  8) Update flake inputs and rebuild
  9) Drop to shell

EOF
}

prompt_choice() {
  local label="${1:-Enter an option}"
  local reply=""

  read -r -p "$label: " reply
  printf '%s\n' "$reply"
}

pause_invalid() {
  pause "${1:-Invalid selection. Press Enter to continue.}"
}

format_key_label() {
  local key="$1"

  if [ "${#key}" -gt 72 ]; then
    printf '%s...\n' "${key:0:69}"
  else
    printf '%s\n' "$key"
  fi
}

manage_ssh_keys() {
  local selection=""
  local value=""
  local current_keys=()
  local index=1

  while true; do
    mapfile -t current_keys < <(nixoa_tui_ssh_keys)
    clear_screen
    current_header
    cat <<'EOF'
 SSH Key Management

  1) Set primary SSH key
  2) Add SSH key
  3) Remove SSH key
  4) Return to main menu

EOF

    if [ "${#current_keys[@]}" -gt 0 ]; then
      echo " Current keys:"
      index=1
      for value in "${current_keys[@]}"; do
        printf '  %s. %s\n' "$index" "$(format_key_label "$value")"
        index=$((index + 1))
      done
      echo ""
    fi

    selection="$(prompt_choice)"

    case "$selection" in
      1)
        value="$(prompt_required "SSH public key")"
        run_action set-ssh-key "$value"
        return 0
        ;;
      2)
        value="$(prompt_required "SSH public key")"
        run_action add-ssh-key "$value"
        return 0
        ;;
      3)
        if [ "${#current_keys[@]}" -eq 0 ]; then
          pause "No SSH keys are configured."
          continue
        fi

        while true; do
          selection="$(prompt_choice "Remove key number")"

          if [ "$selection" = "0" ] || [ -z "$selection" ]; then
            break
          fi

          if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#current_keys[@]}" ]; then
            run_action remove-ssh-key "${current_keys[$((selection - 1))]}"
            return 0
          fi

          pause_invalid "Invalid key number. Enter a listed number or 0 to cancel."
          clear_screen
          current_header
          echo " SSH Key Management"
          echo ""
          echo " Select the key number to remove, or 0 to cancel."
          echo ""
          index=1
          for value in "${current_keys[@]}"; do
            printf '  %s) %s\n' "$index" "$(format_key_label "$value")"
            index=$((index + 1))
          done
          echo ""
        done
        ;;
      4)
        return 0
        ;;
      *)
        pause_invalid
        ;;
    esac
  done
}

while true; do
  clear_screen
  current_header
  show_menu
  selection="$(prompt_choice)"

  case "$selection" in
    1)
      value="$(prompt_default "Hostname" "$(nixoa_tui_hostname)")"
      run_action set-hostname "$value"
      ;;
    2)
      value="$(prompt_default "Username" "$(nixoa_tui_username)")"
      run_action set-username "$value"
      ;;
    3)
      manage_ssh_keys
      ;;
    4)
      run_action toggle-extras
      ;;
    5)
      value="$(prompt_required "System package attr")"
      run_action add-system-package "$value"
      ;;
    6)
      value="$(prompt_required "User package attr")"
      run_action add-user-package "$value"
      ;;
    7)
      value="$(prompt_required "Service path (for example tailscale)")"
      run_action add-service "$value"
      ;;
    8)
      run_action update-rebuild
      ;;
    9)
      export NIXOA_TUI_BYPASS=1
      exec "${SHELL:-/run/current-system/sw/bin/bash}" -l
      ;;
    q|Q)
      export NIXOA_TUI_BYPASS=1
      exec "${SHELL:-/run/current-system/sw/bin/bash}" -l
      ;;
    *)
      pause_invalid
      ;;
  esac
done
