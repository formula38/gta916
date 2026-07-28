# FiveM Foundation (Homelab)

This document sets up a local/private GTA916 FiveM foundation using official artifacts and txAdmin.

## 1) Prerequisites

- Ubuntu/Debian host (WSL/dev is fine for local prep; production homelab should be native Linux VM or bare metal)
- 4+ CPU cores, 8 GB RAM minimum (16 GB preferred), SSD storage
- Open ports:
  - `30120` TCP/UDP for player traffic
  - `40120` TCP for txAdmin UI
- Accounts and keys:
  - Cfx.re account
  - server license key from Cfx.re Keymaster/Portal

## 2) Runtime folder model

Use a split between server binaries and server data:

- `server/` for FiveM artifacts
- `txData/` for txAdmin profiles/config/resources

Recommended host path example:

- `/opt/gta916/server`
- `/opt/gta916/txData`

## 3) Download official artifacts

Run `ops/homelab/bootstrap.sh` — it scaffolds the runtime layout and downloads the latest RECOMMENDED Linux build automatically.

Notes learned from real setup:

- The old `.../master/latest/fx.tar.xz` shortcut URL no longer exists. The script parses the artifact listing page and picks the build marked "LATEST RECOMMENDED" (not the newest optional build).
- The installed build id is recorded in `<base_dir>/server/ARTIFACT_VERSION` for upgrade tracking.
- To upgrade later: move `<base_dir>/server` aside and re-run `bootstrap.sh`. Your `txData` is untouched.

## 4) First start and txAdmin bootstrap

Start via the launcher script (from the repo root):

```bash
./ops/homelab/start-server.sh    # defaults to ~/gta916
```

txAdmin v8 notes:

- `+set serverProfile` and `+set txAdminPort` are deprecated. The launcher sets `TXHOST_DATA_PATH` instead (and `TXHOST_TXA_PORT` exists for a custom panel port).
- Do not pre-create `txData/default` by hand. txAdmin creates the profile on first boot and fails with error `E5110` if the folder exists without a `config.json`.

Then:

1. Open `http://<host-ip>:40120` (or `http://localhost:40120` when local).
2. Enter the 4-digit pin shown in console.
3. Link Cfx.re account and create admin credentials.
4. Use recipe deployer (default first or QBCore if ready), or point it at existing server data wired in step 5.

## 5) Base config wiring

After the first boot created the profile, wire the repo into it:

```bash
./ops/homelab/wire-profile.sh    # defaults to ~/gta916 and profile 'default'
```

This does four things:

- installs `server.cfg` from `ops/homelab/server.cfg.template` (kept sanitized in git)
- installs `server.cfg.local` from the example — put your real `sv_licenseKey` here; the file is gitignored and lives only on the host
- clones `cfx-server-data` and symlinks its resource categories — the default resources (`mapmanager`, `chat`, `spawnmanager`, `sessionmanager`, `basic-gamemode`, etc.) are NOT bundled in the server artifact, and players cannot spawn without them
- symlinks `resources/[gta916]` from the repo into the profile, so resource edits in the repo go live with a `restart gta916-core` in the server console (no copy/deploy step)

Note on visibility: the template ships with `sv_master1 ""` (private mode, not announced to the public server list). Without it, a non-internet-reachable server logs `Server list query returned an error ... context deadline exceeded` — harmless, but noisy. Remove that line in Phase 2 when going public with proper port forwarding.

The scripts are idempotent: existing `server.cfg`/`server.cfg.local` files are kept, and the symlink is refreshed.

## 6) Recommended first-run order

1. Boot with default recipe and verify server stability.
2. Introduce QBCore recipe/dependencies.
3. Add `gta916-core` custom resource.
4. Validate using `docs/setup/private-smoke-tests.md`.

## 7) Upgrade hygiene

- Track artifact version changes in a changelog note.
- Update on maintenance windows only.
- Keep rollback copy of last-known-good artifact folder.
