# SPDX-License-Identifier: Apache-2.0
# Build a Nix representation of /etc/xo-server/config.toml
# Reads from ../xo-server-settings.toml and system config

systemConfig:
let
  # Read and parse the XO server settings TOML
  xoSettingsPath = ../xo-server-settings.toml;
  xoSettingsContent = builtins.readFile xoSettingsPath;
  xoSettings = builtins.fromTOML xoSettingsContent;

  # Extract settings with fallbacks
  xo   = xoSettings.xo or { };
  tls  = xoSettings.tls or { };
  auth = xoSettings.authentication or { };
  logs = xoSettings.logs or { };
  paths = xoSettings.paths or { };

  # Also get storage settings from system config
  stor = systemConfig.storage or { };

  xoPort      = xo.port or 80;
  xoHttpsPort = xo.httpsPort or 443;

  tlsEnabled       = tls.enable or true;
  redirectToHttps  = (tls.redirectToHttps or true) && tlsEnabled;

  # Prefer paths from xo-server-settings, fallback to system config, then defaults
  mountsDir  = paths.mountsDir or (stor.mountsDir or "/var/lib/xo/mounts");

  # These paths should match what xoa.nix uses by default
  xoHome        = "/var/lib/xo";
  webMountDir   = "${xoHome}/xen-orchestra/packages/xo-web/dist";
  webMountDirV6 = "${xoHome}/xen-orchestra/@xen-orchestra/web/dist";
  dataDir       = paths.dataDir or "${xoHome}/data";
  tempDir       = paths.tempDir or "${xoHome}/tmp";
in
{
  http = {
    inherit redirectToHttps;

    listen =
      [ { port = xoPort; } ]
      ++ (if tlsEnabled then [
        {
          port = xoHttpsPort;
          cert = tls.cert or "/etc/ssl/xo/certificate.pem";
          key  = tls.key  or "/etc/ssl/xo/key.pem";
        }
      ] else [ ]);

    mounts = {
      "/"  = webMountDir;
      "/v6" = webMountDirV6;
    };
  };

  redis.socket = "/run/redis-xo/redis.sock";

  authentication.defaultTokenValidity = auth.defaultTokenValidity or "30 days";

  logs.level = logs.level or "info";

  dataStore.path = dataDir;

  tempDir.path = tempDir;

  remoteOptions = {
    useSudo   = true;
    mountsDir = mountsDir;
  };
}
