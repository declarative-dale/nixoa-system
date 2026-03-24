{
  inputs,
  vars,
  ...
}:
let
  system = "x86_64-linux";
in
{
  den.hosts.${system}.${vars.hostname} = {
    aspect = "nixoaHost";
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
      aspect = "nixoaUser";
      userName = vars.username;
    };
  };
}
