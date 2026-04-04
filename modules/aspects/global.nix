{
  den,
  vars,
  ...
}:
{
  den.default = {
    includes = [
      den._.hostname
      den._.define-user
    ];

    # Keep host and HM state versions aligned with the host config source of truth.
    nixos.system.stateVersion = vars.stateVersion;
    homeManager.home.stateVersion = vars.stateVersion;
  };

  den.ctx.user.includes = [ den._.mutual-provider ];
}
