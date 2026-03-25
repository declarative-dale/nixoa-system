{
  inputs,
  vars,
  ...
}:
{
  den.aspects.${vars.hostname}.nixos = {
    imports = [
      ../nixos/core/overlay.nix
      ../nixos/runtime/determinate.nix
      ../nixos/runtime/nix-settings.nix
      ../nixos/core/appliance.nix
      ../nixos/host/boot.nix
      ../nixos/host/hardware.nix
      ../nixos/host/time.nix
      ../nixos/host/packages.nix
      ../nixos/host/extras.nix
      ../nixos/host/firewall.nix
      ../nixos/host/accounts.nix
      ../nixos/host/ssh.nix
      ../nixos/host/sudo.nix
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
