{
  vars,
  ...
}:
{
  # Keep HM state version aligned with the host config source of truth.
  den.default.homeManager.home.stateVersion = vars.stateVersion;
}
