{
  vars,
  ...
}:
{
  den.aspects.${vars.username}.homeManager = import ./_user/user/home.nix;
}
