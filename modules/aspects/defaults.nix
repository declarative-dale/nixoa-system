{
  den,
  vars,
  ...
}:
{
  den.default = {
    includes = [ den.provides.hostname ];

    # Keep HM state version aligned with the host config source of truth.
    homeManager.home.stateVersion = vars.stateVersion;
  };
}
