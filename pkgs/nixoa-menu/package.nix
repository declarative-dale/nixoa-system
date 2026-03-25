{
  lib,
  git,
  writeShellApplication,
}:

writeShellApplication {
  name = "nixoa-menu";
  runtimeInputs = [
    git
  ];

  text = ''
    set -euo pipefail

    repo_root="''${NIXOA_SYSTEM_ROOT:-}"
    if [ -z "$repo_root" ]; then
      if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
        repo_root="$git_root"
      elif [ -n "''${HOME:-}" ] && [ -d "''${HOME}/system" ]; then
        repo_root="''${HOME}/system"
      else
        repo_root="$PWD"
      fi
    fi

    script="$repo_root/scripts/tui/menu.sh"
    if [ ! -x "$script" ]; then
      echo "Could not find $script" >&2
      echo "Set NIXOA_SYSTEM_ROOT or run this from a NiXOA system checkout." >&2
      exit 1
    fi

    export NIXOA_SYSTEM_ROOT="$repo_root"
    exec "$script" "$@"
  '';

  meta = {
    description = "OPNsense-style SSH administration console for NiXOA system hosts";
    homepage = "https://codeberg.org/NiXOA/system";
    license = lib.licenses.asl20;
    mainProgram = "nixoa-menu";
    platforms = lib.platforms.linux;
  };
}
