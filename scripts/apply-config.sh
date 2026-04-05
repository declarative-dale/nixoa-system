#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Apply the NiXOA configuration with nixos-rebuild

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat <<'EOF'
Usage: apply-config.sh [--hostname HOSTNAME] [--build | --dry-run | --rollback] [--first-install] [extra nixos-rebuild args...]

Options:
  --hostname HOSTNAME  Use a specific flake host output name.
  --build              Build without switching.
  --dry-run            Run a dry-build preview.
  --rollback           Roll back to the previous system generation.
  --first-install      Add Determinate first-install cache flags for the initial switch.
  --help               Show this help text.
EOF
}

hostname_arg="${NIXOA_HOSTNAME:-$(nixoa_default_hostname)}"
rebuild_action="switch"
record_action="switch"
first_install=0
rollback=0
extra_args=()

while [ $# -gt 0 ]; do
  case "$1" in
    --hostname)
      hostname_arg="$2"
      shift 2
      ;;
    --build)
      rebuild_action="build"
      shift
      ;;
    --dry-run)
      rebuild_action="dry-build"
      record_action="dry-build"
      shift
      ;;
    --rollback)
      rollback=1
      rebuild_action="switch"
      record_action="rollback"
      shift
      ;;
    --first-install)
      first_install=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    --)
      shift
      extra_args+=("$@")
      break
      ;;
    *)
      extra_args+=("$1")
      shift
      ;;
  esac
done

nixoa_cd_root

if [ "$rollback" -ne 1 ] && nixoa_has_changes; then
  "$SCRIPT_DIR/commit-config.sh"
fi

current_head="$(git -C "$NIXOA_SYSTEM_ROOT" rev-parse HEAD 2>/dev/null || true)"

if [ "$rollback" -eq 1 ]; then
  rebuild_cmd=(
    nixos-rebuild
    switch
    --rollback
    -L
  )
else
  rebuild_cmd=(
    nixos-rebuild
    "$rebuild_action"
    --flake
    ".#${hostname_arg}"
    -L
  )
fi

if [ "$first_install" -eq 1 ]; then
  rebuild_cmd+=(
    --option
    extra-experimental-features
    "nix-command flakes"
    --option
    extra-substituters
    "https://install.determinate.systems"
    --option
    extra-trusted-public-keys
    "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
  )
fi

rebuild_cmd+=("${extra_args[@]}")

if [ "$EUID" -ne 0 ]; then
  sudo_bin="$(nixoa_sudo_bin)" || exit 1
  rebuild_cmd=("$sudo_bin" "${rebuild_cmd[@]}")
fi

printf 'Running:'
printf ' %q' "${rebuild_cmd[@]}"
printf '\n'

if "${rebuild_cmd[@]}"; then
  nixoa_write_apply_state "success" "$record_action" "$hostname_arg" "$current_head" "$first_install" "0"
else
  exit_code="$?"
  nixoa_write_apply_state "failed" "$record_action" "$hostname_arg" "$current_head" "$first_install" "$exit_code"
  exit "$exit_code"
fi
