{
  inputs,
  vars,
  ...
}:
let
  system = vars.hostSystem;
in
{
  den.hosts.${system}.${vars.hostname} = {
    hostName = vars.hostname;

    instantiate =
      { modules, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs = {
          inherit inputs vars;
        };
      };

    users.${vars.username} = {
      userName = vars.username;
    };
  };
}
