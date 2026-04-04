{
  inputs,
  vars,
  ...
}:
let
  system = vars.hostSystem;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  nixoaMenu = inputs.nixoaCore.packages.${system}.nixoa-menu;
  mkRepoScriptApp =
    {
      appName,
      scriptName,
      description,
    }:
    {
      type = "app";
      program = toString (
        pkgs.writeShellScript appName ''
          set -euo pipefail

          repo_root="''${NIXOA_SYSTEM_ROOT:-}"
          if [ -z "$repo_root" ]; then
            if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
              repo_root="$git_root"
            else
              repo_root="$PWD"
            fi
          fi

          script="$repo_root/scripts/${scriptName}"
          if [ ! -x "$script" ]; then
            echo "Could not find $script" >&2
            echo "Run this app from a NiXOA system checkout or set NIXOA_SYSTEM_ROOT." >&2
            exit 1
          fi

          exec "$script" "$@"
        ''
      );
      meta.description = description;
    };
in
{
  flake.apps.${system} = {
    apply = mkRepoScriptApp {
      appName = "nixoa-apply";
      scriptName = "apply-config.sh";
      description = "Apply the NiXOA system configuration";
    };

    bootstrap = mkRepoScriptApp {
      appName = "nixoa-bootstrap";
      scriptName = "bootstrap.sh";
      description = "Bootstrap a NiXOA system checkout on a fresh host";
    };

    commit = mkRepoScriptApp {
      appName = "nixoa-commit";
      scriptName = "commit-config.sh";
      description = "Commit NiXOA system repository changes";
    };

    diff = mkRepoScriptApp {
      appName = "nixoa-diff";
      scriptName = "show-diff.sh";
      description = "Show NiXOA system repository changes";
    };

    history = mkRepoScriptApp {
      appName = "nixoa-history";
      scriptName = "history.sh";
      description = "Show NiXOA system repository history";
    };

    menu = {
      type = "app";
      program = "${nixoaMenu}/bin/nixoa-menu";
      meta.description = "Launch the NiXOA SSH administration TUI";
    };
  };
}
