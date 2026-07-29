# GTA916 Foundation

Private, homelab-first foundation for a GTA roleplay ecosystem focused on players in (or interested in) the 916 area.

This repository separates three concerns:

- server runtime (`FiveM` + `QBCore` + custom resources)
- content operations (faceless YouTube and streaming workflows)
- growth/marketing operations (campaign assets and channel strategy)

## Repository layout

- `qb-core/` - your forked QBCore upstream base
- `resources/[gta916]/gta916-core/` - GTA916 custom resource foundation
- `ops/homelab/` - local bootstrap + server config templates
- `docs/setup/` - technical setup and smoke testing docs
- `docs/policy/` - monetization and compliance guardrails
- `docs/strategy/` - audience and channel strategy docs
- `channels/` - content production playbooks

## Quickstart (homelab)

GTA916 targets **FiveM for GTAV Enhanced** (early access since July 21, 2026).
See `docs/setup/gtav-enhanced.md` for background and caveats.

1. Read `docs/setup/fivem-foundation.md`, then `docs/setup/gtav-enhanced.md`.
2. `./ops/homelab/bootstrap-enhanced.sh` — scaffolds `~/gta916` and downloads the current Cfx Server (Enhanced) build.
3. `./ops/homelab/start-server-enhanced.sh` — first boot; open `http://localhost:40120`, enter the console PIN, link your Cfx.re account.
4. `./ops/homelab/wire-profile.sh ~/gta916 default txData-enhanced` — installs `server.cfg` + `server.cfg.local` and symlinks repo resources into the profile.
5. Put your real `sv_licenseKey` in `~/gta916/txData-enhanced/default/server.cfg.local` (gitignored), then restart the server.
6. Run the checks in `docs/setup/private-smoke-tests.md`.

The legacy (pre-Enhanced) flow still works via `bootstrap.sh` / `start-server.sh`
/ `wire-profile.sh` with default args, and the legacy runtime in `~/gta916/server`
+ `~/gta916/txData` is kept as a fallback. Only run one server at a time — both
use ports 30120/40120.

Handy URLs once running:

- `http://localhost:40120` - txAdmin control panel
- `http://localhost:30120/gta916-core/` - human-readable server status page (the bare `:30120` root just redirects to cfx.re and is not useful for a private server)
- `http://localhost:30120/gta916-core/health` - status JSON for scripts/monitoring

## Connect and play (client side)

The steps above run the SERVER. To actually get in the game you need the FiveM
client on a Windows gaming machine:

1. Own and install GTA V Enhanced on Windows (Steam, Epic, or Rockstar). FiveM
   requires a legitimate copy but does NOT modify your GTA V install, and using
   FiveM does not risk your GTA:Online account.
2. Download the **FiveM for GTAV Enhanced** client from `https://fivem.net` and
   run the installer. (It is a separate launcher from legacy FiveM; the legacy
   client only works with GTA V Legacy and the legacy server.)
3. Launch it. It will locate your GTA V Enhanced install on first run and log
   you in with your Cfx.re account (same one used for txAdmin).
4. Connect to your private server: press `F8` to open the console and type:

   ```
   connect localhost:30120
   ```

   (If the client runs on a different PC than the server, use the server
   machine's LAN IP, e.g. `connect 192.168.1.50:30120`.)
5. You will spawn into the default freeroam map. There is no character
   creation yet - persistent characters, jobs, and money arrive when the
   QBCore framework layer is deployed (see `docs/setup/qbcore-stack.md`).
6. Verify the custom resource: type `/gta916ping` in chat (`T`). You should
   get a `pong` back from `gta916-core`.

WSL2 note: Windows forwards `localhost` to WSL2 automatically, so connecting
from the same laptop with `localhost:30120` works. From another PC on your
LAN you would need Windows port-forwarding rules (Phase 2 territory).

## Development workflow

See `docs/dev-workflow.md` for the file map (what to edit, when, and why), the live dev loop (repo symlink → `restart gta916-core`), and the current CI/CD state.

## Notes

- Do not commit secrets (license keys, Tebex secrets, database passwords).
- Use `server.cfg.local` for real keys/secrets and keep template files sanitized.
- Keep `qb-core/` aligned with upstream, and place GTA916-specific behavior in custom resources when possible.

## Local secret protection

Install the local pre-commit secret scanner:

```bash
./scripts/security/install-hooks.sh
```

The hook runs `gitleaks` if installed, or falls back to targeted secret-pattern checks.
