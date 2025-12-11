# SPDX-License-Identifier: Apache-2.0
# Build a Nix representation of /etc/xo-server/config.toml
# This is a 1:1 pass-through from xo-server-settings.toml to the generated config
# Whatever you configure in xo-server-settings.toml appears exactly in /etc/xo-server/config.toml

systemConfig:
let
  # Read and parse the XO server settings TOML
  xoSettingsPath = ../xo-server-settings.toml;

  # Check if file exists
  xoSettings =
    if !builtins.pathExists xoSettingsPath then
      builtins.throw ''
        nixoa-ce-config: xo-server-settings.toml is missing!

        Please ensure the file exists at: ${toString xoSettingsPath}
      ''
    else
      builtins.fromTOML (builtins.readFile xoSettingsPath);

  # Extract all sections from TOML
  http = xoSettings.http or {};
  tls = xoSettings.tls or {};
  redis = xoSettings.redis or {};
  authentication = xoSettings.authentication or {};
  logs = xoSettings.logs or {};
  dataStore = xoSettings.dataStore or {};
  tempDir = xoSettings.tempDir or {};
  remoteOptions = xoSettings.remoteOptions or {};

  # HTTP listen configuration
  httpListen = http.listen or {};
  httpPort = (httpListen.http or {}).port or 80;
  httpsPort = (httpListen.https or {}).port or 443;

  # TLS configuration
  tlsEnabled = tls.enable or true;
  tlsCert = tls.cert or "/etc/ssl/xo/certificate.pem";
  tlsKey = tls.key or "/etc/ssl/xo/key.pem";

  # HTTP mounts (pass through directly from TOML)
  httpMounts = http.mounts or {
    "/" = "/var/lib/xo/xen-orchestra/packages/xo-web/dist";
    "/v6" = "/var/lib/xo/xen-orchestra/@xen-orchestra/web/dist";
  };

  # redirectToHttps only applies when TLS is enabled
  redirectToHttps = (http.redirectToHttps or true) && tlsEnabled;

  # Build the http.listen array conditionally
  # Always include HTTP port, add HTTPS port only when TLS enabled
  listenArray =
    [ { port = httpPort; } ]
    ++ (if tlsEnabled then [
      {
        port = httpsPort;
        cert = tlsCert;
        key = tlsKey;
      }
    ] else []);
in
{
  # HTTP Configuration
  http = {
    inherit redirectToHttps;
    listen = listenArray;
    mounts = httpMounts;
  };

  # Redis Configuration (pass through)
  redis = {
    socket = redis.socket or "/run/redis-xo/redis.sock";
  };

  # Authentication Configuration (pass through)
  authentication = {
    defaultTokenValidity = authentication.defaultTokenValidity or "30 days";
  };

  # Logging Configuration (pass through)
  logs = {
    level = logs.level or "info";
  };

  # Data Store Configuration (pass through)
  dataStore = {
    path = dataStore.path or "/var/lib/xo/data";
  };

  # Temp Directory Configuration (pass through)
  tempDir = {
    path = tempDir.path or "/var/lib/xo/tmp";
  };

  # Remote Options Configuration (pass through)
  remoteOptions = {
    useSudo = remoteOptions.useSudo or true;
    mountsDir = remoteOptions.mountsDir or "/var/lib/xo/mounts";
  };

  # Pass through any additional sections from TOML that aren't explicitly handled above
  # This allows users to add custom XO configuration sections
  # Filter out the sections we've already processed
} // (builtins.removeAttrs xoSettings [
  "http" "tls" "redis" "authentication" "logs" "dataStore" "tempDir" "remoteOptions"
])
