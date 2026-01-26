{
  inputs,
  ...
}:
{
  flake.modules.nixos.vm = {
    imports = [ inputs.self.modules.nixos.nixoaSystem ];
  };
}
