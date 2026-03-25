#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Bootstrap a fresh NiXOA system checkout on a NixOS host

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [options]

Options:
  --repo-dir PATH       Checkout directory. Defaults to $HOME/system.
  --repo-url URL        System repository URL.
  --branch NAME         Branch to clone or update. Defaults to beta.
  --enable-flakes       Persist nix-command + flakes before validation.
  --hostname NAME       Hostname. Defaults to nixoa.
  --username NAME       Primary username. Defaults to nixoa.
  --timezone ZONE       Time zone. Defaults to Europe/Paris.
  --state-version VER   Write stateVersion into config/overrides.nix.
  --ssh-key KEY         Add an SSH public key. Repeatable. At least one key is required.
  --skip-check          Skip nix flake check.
  --skip-hardware-copy  Do not copy /etc/nixos/hardware-configuration.nix.
  --first-switch        Run apply-config.sh --first-install after setup.
  --help                Show this help text.
EOF
}

nix_quote() {
  printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
}

repo_url="https://codeberg.org/NiXOA/system.git"
branch="beta"
repo_dir="${HOME:-/root}/system"
default_hostname="nixoa"
default_username="nixoa"
default_timezone="Europe/Paris"
enable_flakes=0
skip_check=0
skip_hardware_copy=0
first_switch=0
hostname_arg=""
username_arg=""
timezone_arg=""
state_version_arg=""
declare -a ssh_keys=()

prompt_with_default() {
  local prompt="$1"
  local default_value="$2"
  local reply=""

  if [ ! -t 0 ]; then
    printf '%s\n' "$default_value"
    return 0
  fi

  read -r -p "$prompt [$default_value]: " reply
  printf '%s\n' "${reply:-$default_value}"
}

prompt_required() {
  local prompt="$1"
  local reply=""

  if [ ! -t 0 ]; then
    echo "Error: $prompt is required. Pass it with --ssh-key in non-interactive mode." >&2
    exit 1
  fi

  while [ -z "$reply" ]; do
    read -r -p "$prompt: " reply
  done

  printf '%s\n' "$reply"
}

flakes_are_enabled() {
  if nix show-config experimental-features >/dev/null 2>&1; then
    local features
    features="$(nix show-config experimental-features 2>/dev/null || true)"
    printf '%s' "$features" | grep -Eq 'nix-command' \
      && printf '%s' "$features" | grep -Eq 'flakes'
    return $?
  fi

  return 1
}

enable_flakes_now() {
  local target_file
  local target_dir

  if flakes_are_enabled; then
    if [ -n "${NIX_CONFIG:-}" ]; then
      export NIX_CONFIG=$'experimental-features = nix-command flakes\n'"$NIX_CONFIG"
    else
      export NIX_CONFIG='experimental-features = nix-command flakes'
    fi
    echo "Flakes are already enabled."
    return 0
  fi

  if [ "$(id -u)" -eq 0 ]; then
    target_file="/etc/nix/nix.conf"
    install -d -m 0755 /etc/nix
  else
    target_file="${XDG_CONFIG_HOME:-${HOME:-$repo_dir}/.config}/nix/nix.conf"
    target_dir="$(dirname "$target_file")"
    install -d -m 0755 "$target_dir"
  fi

  if [ -f "$target_file" ] \
    && grep -Eq '^[[:space:]]*experimental-features[[:space:]]*=.*nix-command' "$target_file" \
    && grep -Eq '^[[:space:]]*experimental-features[[:space:]]*=.*flakes' "$target_file"
  then
    echo "Flakes are already configured in $target_file"
    return 0
  fi

  {
    printf '\n# Added by NiXOA bootstrap\n'
    printf 'experimental-features = nix-command flakes\n'
  } >> "$target_file"

  if [ -n "${NIX_CONFIG:-}" ]; then
    export NIX_CONFIG=$'experimental-features = nix-command flakes\n'"$NIX_CONFIG"
  else
    export NIX_CONFIG='experimental-features = nix-command flakes'
  fi
  echo "Enabled flakes in $target_file"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --repo-dir)
      repo_dir="$2"
      shift 2
      ;;
    --repo-url)
      repo_url="$2"
      shift 2
      ;;
    --branch)
      branch="$2"
      shift 2
      ;;
    --enable-flakes)
      enable_flakes=1
      shift
      ;;
    --hostname)
      hostname_arg="$2"
      shift 2
      ;;
    --username)
      username_arg="$2"
      shift 2
      ;;
    --timezone)
      timezone_arg="$2"
      shift 2
      ;;
    --state-version)
      state_version_arg="$2"
      shift 2
      ;;
    --ssh-key)
      ssh_keys+=("$2")
      shift 2
      ;;
    --skip-check)
      skip_check=1
      shift
      ;;
    --skip-hardware-copy)
      skip_hardware_copy=1
      shift
      ;;
    --first-switch)
      first_switch=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$hostname_arg" ]; then
  hostname_arg="$(prompt_with_default "Hostname" "$default_hostname")"
fi

if [ -z "$username_arg" ]; then
  username_arg="$(prompt_with_default "Username" "$default_username")"
fi

if [ -z "$timezone_arg" ]; then
  timezone_arg="$(prompt_with_default "Time zone" "$default_timezone")"
fi

if [ "${#ssh_keys[@]}" -eq 0 ]; then
  ssh_keys+=( "$(prompt_required "SSH public key")" )
fi

if [ "$enable_flakes" -eq 1 ]; then
  enable_flakes_now
fi

mkdir -p "$(dirname "$repo_dir")"

if [ -d "$repo_dir/.git" ]; then
  echo "Updating existing checkout in $repo_dir"
  git -C "$repo_dir" fetch origin "$branch"
  git -C "$repo_dir" checkout "$branch"
  git -C "$repo_dir" pull --ff-only origin "$branch"
else
  echo "Cloning $repo_url into $repo_dir"
  git clone --branch "$branch" "$repo_url" "$repo_dir"
fi

if [ "$skip_hardware_copy" -eq 0 ] && [ -f /etc/nixos/hardware-configuration.nix ]; then
  install -m 0644 /etc/nixos/hardware-configuration.nix "$repo_dir/hardware-configuration.nix"
  echo "Copied hardware-configuration.nix"
fi

overrides_file="$repo_dir/config/overrides.nix"
{
  echo "# SPDX-License-Identifier: Apache-2.0"
  echo "# Generated by scripts/bootstrap.sh"
  echo "{ ... }:"
  echo "{"
  echo "  hostname = $(nix_quote "$hostname_arg");"
  echo "  username = $(nix_quote "$username_arg");"
  echo "  timezone = $(nix_quote "$timezone_arg");"
  if [ -n "$state_version_arg" ]; then
    echo "  stateVersion = $(nix_quote "$state_version_arg");"
  fi
  echo "  sshKeys = ["
  for ssh_key in "${ssh_keys[@]}"; do
    echo "    $(nix_quote "$ssh_key")"
  done
  echo "  ];"
  echo "}"
} > "$overrides_file"
echo "Wrote $overrides_file"

if [ "$skip_check" -eq 0 ]; then
  echo "Running nix flake check"
  (cd "$repo_dir" && nix flake check --no-write-lock-file)
fi

if [ "$first_switch" -eq 1 ]; then
  switch_host="$hostname_arg"
  echo "Running first switch for ${switch_host}"
  "$repo_dir/scripts/apply-config.sh" --hostname "$switch_host" --first-install
fi

echo ""
echo "Bootstrap complete."
echo "Repository: $repo_dir"
echo "Configured host: $hostname_arg"
echo "Configured user: $username_arg"
echo "Next steps:"
echo "  1. Review overrides in $repo_dir/config/overrides.nix."
echo "  2. Run $repo_dir/scripts/show-diff.sh"
echo "  3. Run $repo_dir/scripts/apply-config.sh"
