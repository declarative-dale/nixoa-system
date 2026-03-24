{
  inputs,
  vars,
  ...
}:
{
  den.aspects.nixoaHost.nixos = {
    imports = [
      ../_nixos/integrations/nixoa-core-overlay.nix
      ../_nixos/runtime/determinate-nix-module.nix
      ../_nixos/runtime/nix-daemon-settings.nix
      ../_nixos/integrations/nixoa-core-appliance.nix
      ../_nixos/host/hardware-profile.nix
      ../_nixos/host/system-packages.nix
      ../_nixos/host/network-firewall.nix
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
