# GTA916 Changelog

Operational log of what changed and why. One entry per working session or
meaningful change. Newest first. Keep entries short - what changed, why, and
anything a future admin/moderator needs to know.

Format per entry:

```
## YYYY-MM-DD - short title
- what changed
- why / context
- follow-ups or gotchas (optional)
```

---

## 2026-07-28 - Added roadmap whitepaper, Cursor rules and skills

- New umbrella doc `docs/strategy/gta916-roadmap-whitepaper.md`: four-phase
  roadmap to mid-October launch with exit criteria, operating model,
  revenue plan, risks, KPIs. Started this changelog.
- Added project Cursor rules (`.cursor/rules/`): core conventions
  (always-on), server-config gotchas, resource development standards.
- Added project Cursor skills (`.cursor/skills/`): `server-ops` (operate/
  troubleshoot the homelab server), `smoke-test` (automated validation),
  `changelog-entry` (this format), `content-drop` (turn milestones into
  channel content). Operational knowledge now loads automatically in
  future agent sessions.

## 2026-07-28 - Migrated to FiveM for GTAV Enhanced (early access)

- Switched the target platform from GTAV Legacy to GTAV Enhanced (early
  access since 2026-07-21). Reason: owner's client machine now runs GTA V
  Enhanced only, and early adoption is a positioning/content advantage.
- Added parallel Enhanced runtime: `server-enhanced/` (Cfx Server binaries,
  build b98-ea, txAdmin v9.0.0-beta) + `txData-enhanced/` profile. Legacy
  runtime kept on disk as fallback but stopped (ports 30120/40120 are shared).
- New ops scripts: `bootstrap-enhanced.sh` (resumable artifact download from
  the official Server Download page), `start-server-enhanced.sh`;
  `wire-profile.sh` now takes a txData dir argument.
- Fixed startup error `Failed to generate cache for set: resource.rpf` from
  mapmanager dynamically starting the freeroam map: pinned
  `ensure fivem-map-hipster` at boot in `server.cfg`. Documented in
  `docs/setup/gtav-enhanced.md` along with other early-access quirks.
- Smoke status: server boots clean, 26 resources up, `gta916-core` status
  page and health JSON verified on `:30120`. Pending: first in-game connect
  with the Enhanced client (`/gta916ping`).

## 2026-07-27 - Foundation hardening and first live server

- Server list query error silenced with `sv_master1 ""` (private mode); this
  stays until Phase 2 public launch.
- Wired `cfx-server-data` default resources (mapmanager, chat, spawnmanager,
  etc.) into the profile via symlinks; added `basic-gamemode` + `baseevents`
  so players can spawn.
- Replaced semicolons with dashes in all `server.cfg` comments (FXServer
  parses `;` as a command separator - caused "No such command" errors).
- Added human-readable status page (`:30120/gta916-core/`) and health JSON
  (`:30120/gta916-core/health`) because the bare `:30120` root redirects to
  cfx.re and confused everyone.
- Added client-side connect instructions to README.

## 2026-07-27 - Initial foundation

- Repo scaffolded: ops scripts (`bootstrap.sh`, `start-server.sh`,
  `wire-profile.sh`), `gta916-core` custom resource, docs (setup, policy,
  strategy), content channel folders (faceless YouTube, streaming,
  marketing).
- qb-core added as a submodule (fork at formula38/qb-core) - not yet
  deployed to the server.
- Secret handling: `server.cfg.local` pattern (gitignored) + pre-commit
  secret scan hook (`scripts/security/install-hooks.sh`). License key lives
  only in runtime `server.cfg.local`, never in the repo.
- First boot completed on GTAV Legacy FXServer (build 25770, txAdmin 8.0.1),
  later superseded by the Enhanced migration above.
