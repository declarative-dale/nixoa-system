# Troubleshooting

## Host Output Not Found

Make sure `hostname` is set in `config/site.nix` or `config/overrides.nix`, then
run:

```bash
nix flake check --no-write-lock-file
```

## SSH Access Missing

Check `sshKeys` in `config/site.nix` or `config/overrides.nix`, then rebuild:

```bash
./scripts/apply-config.sh
```

## Firewall Ports Still Closed

Verify `config/platform.nix` contains the required ports and confirm the build
actually switched on the host.

## XO Service Not Running

```bash
systemctl status xo-server
journalctl -u xo-server -n 200
```

Then verify:

- `enableXO = true` in `config/features.nix`
- runtime/TLS settings in `config/xo.nix`

## Bootstrap Problems

If the raw bootstrap one-liner fails because `curl` or `git` are missing, use
the documented `nix shell nixpkgs#curl nixpkgs#git ...` variant from the
README.
