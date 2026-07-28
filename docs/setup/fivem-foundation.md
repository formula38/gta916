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

Use official FiveM runtime artifact listing and choose latest recommended Linux build.

Example steps:

1. Download artifact archive (`fx.tar.xz`).
2. Extract into `/opt/gta916/server`.
3. Ensure runtime files are executable.

## 4) First start and txAdmin bootstrap

From the server artifact directory:

- run `./run.sh +set serverProfile default`

Then:

1. Open `http://<host-ip>:40120` (or `http://localhost:40120` when local).
2. Enter the 4-digit pin shown in console.
3. Link Cfx.re account and create admin credentials.
4. Use recipe deployer (default first or QBCore if ready).
5. Enter your server license key.

## 5) Base config wiring

- Keep a template in repo: `ops/homelab/server.cfg.template`
- Copy template into runtime profile config.
- Keep real secrets in a local-only overlay file: `server.cfg.local`.
- Use example files as starter:
  - `ops/homelab/server.cfg.local.example`
  - `txData/default/server.cfg.local.example`
- Add custom resource line for `gta916-core` after base dependencies.

Recommended local flow:

1. Copy `ops/homelab/server.cfg.template` to your runtime `server.cfg`.
2. Copy `ops/homelab/server.cfg.local.example` to `server.cfg.local`.
3. Fill real values in `server.cfg.local` only.
4. Do not commit `server.cfg.local` (it is gitignored).

## 6) Recommended first-run order

1. Boot with default recipe and verify server stability.
2. Introduce QBCore recipe/dependencies.
3. Add `gta916-core` custom resource.
4. Validate using `docs/setup/private-smoke-tests.md`.

## 7) Upgrade hygiene

- Track artifact version changes in a changelog note.
- Update on maintenance windows only.
- Keep rollback copy of last-known-good artifact folder.
