{
  den,
  vars,
  ...
}:
{
  den.aspects.${vars.username} = {
    includes = [
      den._.primary-user
      (den._.user-shell (if vars.enableExtras then "zsh" else "bash"))
    ];
    homeManager = import ../home;
  };
}
