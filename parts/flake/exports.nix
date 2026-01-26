{
  inputs,
  ...
}:
{
  flake.nixosModules = {
    system = inputs.self.modules.nixos.nixoaSystem;
    vm = inputs.self.modules.nixos.vm;
    default = inputs.self.modules.nixos.vm;
  };
}
