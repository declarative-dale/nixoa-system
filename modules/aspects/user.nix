{
  den,
  vars,
  ...
}:
{
  den.aspects.${vars.username} = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell (if vars.enableExtras then "zsh" else "bash"))
    ];
    homeManager = import ../home;
  };
}
