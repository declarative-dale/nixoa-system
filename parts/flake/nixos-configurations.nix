{
  inputs,
  ...
}:
let
  pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  vars = import ../../settings.nix {
    inherit (inputs.nixpkgs) lib;
    inherit pkgs;
  };
in
{
  flake.nixosConfigurations.${vars.hostname} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit vars; };
    modules = [ inputs.self.modules.nixos.vm ];
  };
}
