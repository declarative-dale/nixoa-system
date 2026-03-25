{
  den,
  vars,
  ...
}:
{
  den.default = {
    includes = [ den.provides.hostname ];

    # Keep host and HM state versions aligned with the host config source of truth.
    nixos.system.stateVersion = vars.stateVersion;
    homeManager.home.stateVersion = vars.stateVersion;
  };
}
