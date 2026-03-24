{
  inputs,
  vars,
  ...
}:
{
  den.aspects.${vars.hostname}.nixos = {
    imports = [
      ./_nixos/foundation/overlays.nix
      ./_nixos/foundation/determinate.nix
      ./_nixos/foundation/nix-settings.nix
      ./_nixos/core/appliance.nix
      ./_nixos/host/hardware.nix
      ./_nixos/host/packages.nix
      ./_nixos/host/firewall.nix
    ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
      extraSpecialArgs = {
        inherit inputs vars;
      };
    };
  };
}
