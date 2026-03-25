#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib.sh"

nixoa_require_git_repo

mapfile -t ssh_keys < <(nixoa_tui_ssh_keys)
mapfile -t system_packages < <(nixoa_tui_extra_system_packages)
mapfile -t user_packages < <(nixoa_tui_extra_user_packages)
mapfile -t services < <(nixoa_tui_enabled_services)

printf 'hostname=%s\n' "$(nixoa_tui_hostname)"
printf 'username=%s\n' "$(nixoa_tui_username)"
printf 'timezone=%s\n' "$(nixoa_tui_timezone)"
printf 'extras=%s\n' "$(nixoa_tui_enable_extras)"
printf 'ssh_key_count=%s\n' "${#ssh_keys[@]}"
printf 'system_package_count=%s\n' "${#system_packages[@]}"
printf 'user_package_count=%s\n' "${#user_packages[@]}"
printf 'service_count=%s\n' "${#services[@]}"
printf 'dirty_count=%s\n' "$(nixoa_tui_dirty_count)"
