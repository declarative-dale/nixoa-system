#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Apply the NiXOA configuration with nixos-rebuild

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

usage() {
  cat <<'EOF'
Usage: apply-config.sh [--hostname HOSTNAME] [--build | --dry-run] [--first-install] [extra nixos-rebuild args...]

Options:
  --hostname HOSTNAME  Use a specific flake host output name.
  --build              Build without switching.
  --dry-run            Run a dry-build preview.
  --first-install      Add Determinate's install cache flags for the first switch.
  --help               Show this help text.
EOF
}

hostname_arg="${NIXOA_HOSTNAME:-$(nixoa_default_hostname)}"
rebuild_action="switch"
first_install=0
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

rebuild_cmd=(
  nixos-rebuild
  "$rebuild_action"
  --flake
  ".#${hostname_arg}"
  -L
)

if [ "$first_install" -eq 1 ]; then
  rebuild_cmd+=(
    --option
    extra-substituters
    https://install.determinate.systems
    --option
    extra-trusted-public-keys
    cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM=
  )
fi

rebuild_cmd+=("${extra_args[@]}")

if [ "$EUID" -ne 0 ]; then
  rebuild_cmd=(sudo "${rebuild_cmd[@]}")
fi

printf 'Running:'
printf ' %q' "${rebuild_cmd[@]}"
printf '\n'

exec "${rebuild_cmd[@]}"
