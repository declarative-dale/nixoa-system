# SPDX-License-Identifier: Apache-2.0
# Host time settings
{
  vars,
  ...
}:
{
  time.timeZone = vars.timezone;
}
