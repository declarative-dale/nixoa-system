{
  inputs,
  lib,
  vars,
  ...
}:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in
{
  flake = lib.optionalAttrs vars.enableExtras {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        curl
        git
        jq
        nix-diff
        nix-tree
        nixos-rebuild
        ripgrep
      ];

      shellHook = ''
        echo "NiXOA system dev shell (extras enabled)"
      '';
    };
  };
}
