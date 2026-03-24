{
  inputs,
  lib,
  vars,
  ...
}:
let
  system = "x86_64-linux";
in
{
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.hosts.${system}.${vars.hostname} = {
    instantiate =
      { modules, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs = {
          inherit inputs vars;
        };
      };

    users.${vars.username} = { };
  };
}
