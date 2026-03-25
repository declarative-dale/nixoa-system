{ vars, ... }:
{
  den.aspects.${vars.username}.homeManager = import ../home;
}
