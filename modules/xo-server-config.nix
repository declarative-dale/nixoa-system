# SPDX-License-Identifier: Apache-2.0
# Build a Nix representation of /etc/xo-server/config.toml
# Argument is the attrset from modules/system.nix

systemConfig:
let
  xo   = systemConfig.xo or { };
  tls  = systemConfig.tls or { };
  stor = systemConfig.storage or { };

  xoPort      = xo.port or 80;
  xoHttpsPort = xo.httpsPort or 443;

  tlsEnabled       = tls.enable or true;
  redirectToHttps  = (tls.redirectToHttps or true) && tlsEnabled;

  mountsDir  = stor.mountsDir or "/var/lib/xo/mounts";

  # These paths should match what xoa.nix uses by default
  xoHome        = "/var/lib/xo";
  webMountDir   = "${xoHome}/xen-orchestra/packages/xo-web/dist";
  webMountDirV6 = "${xoHome}/xen-orchestra/@xen-orchestra/web/dist";
  dataDir       = "${xoHome}/data";
  tempDir       = "${xoHome}/tmp";
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

  authentication.defaultTokenValidity = "30 days";

  logs.level = "info";

  dataStore.path = dataDir;

  tempDir.path = tempDir;

  remoteOptions = {
    useSudo   = true;
    mountsDir = mountsDir;
  };
}
