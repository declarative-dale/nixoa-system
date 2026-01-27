# Troubleshooting

## Rebuild fails with missing hostname

Ensure `config/host.nix` defines `hostname`:

```nix
{ hostname = "nixoa"; }
```

## SSH access not working

Check `config/users.nix`:

```nix
{ sshKeys = [ "ssh-ed25519 AAAA... user@host" ]; }
```

Then rebuild:

```bash
./scripts/apply-config.sh "Fix SSH keys"
```

## Firewall ports blocked

Update `config/networking.nix`:

```nix
{
  allowedTCPPorts = [ 22 80 443 ];
  allowedUDPPorts = [ 53 ];
}
```

## XO service not running

```bash
systemctl status xo-server
journalctl -u xo-server -n 200
```

Verify `config/features.nix`:

```nix
{ enableXO = true; }
```

## Core input update issues

If `nix flake update` fails, check your network and try again. You can pin a
specific core ref in `flake.nix` if needed.
