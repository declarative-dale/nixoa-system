# SPDX-License-Identifier: Apache-2.0
# Nix settings aligned with Determinate Nix (use extra-* to avoid overrides)
{ ... }:
{
  nix.settings = {
    # Determinate Nix provides its own cache; use extra-* to append.
    extra-substituters = [
      "https://xen-orchestra-ce.cachix.org"
    ];

    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "xen-orchestra-ce.cachix.org-1:WAOajkFLXWTaFiwMbLidlGa5kWB7Icu29eJnYbeMG7E="
    ];

    trusted-users = [
      "root"
      "@wheel"
    ];
  };
}
