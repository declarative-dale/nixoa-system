# Re-export packages from core flake
{ inputs, ... }:
{
  flake.packages.x86_64-linux = {
    # Re-export core packages for easy building and caching
    inherit (inputs.core.packages.x86_64-linux)
      xen-orchestra-ce
      libvhdi
      ;
  };
}
