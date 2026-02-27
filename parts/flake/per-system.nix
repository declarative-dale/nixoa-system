{
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      lib = pkgs.lib;
      vars = import ../../modules/user-configuration.nix {
        inherit lib pkgs;
      };
    in
    {
      devShells = lib.optionalAttrs vars.enableExtras {
        default = pkgs.mkShell {
          packages = with pkgs; [
            jq
            git
            curl
            nixos-rebuild
            nix-tree
            nix-diff
          ];

          shellHook = ''
            echo "NiXOA system dev shell (extras enabled)"
          '';
        };
      };

      apps = {
        commit = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "commit-config" ''
              ${builtins.readFile ../../scripts/commit-config.sh}
            ''
          );
          meta.description = "Commit configuration changes to git";
        };

        apply = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "apply-config" ''
              ${builtins.readFile ../../scripts/apply-config.sh}
            ''
          );
          meta.description = "Apply configuration changes to the system";
        };

        diff = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "show-diff" ''
              ${builtins.readFile ../../scripts/show-diff.sh}
            ''
          );
          meta.description = "Show configuration differences";
        };

        history = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "history" ''
              ${builtins.readFile ../../scripts/history.sh}
            ''
          );
          meta.description = "Show configuration commit history";
        };
      };
    };
}
