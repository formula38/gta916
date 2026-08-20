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

## 2026-08-19 - MariaDB deployed (transactional layer live)

- MariaDB 11.4 running as Docker container `gta916-mariadb` (port 3306
  bound to localhost, data persisted in `~/gta916/mariadb-data`,
  `--restart unless-stopped`). New idempotent `ops/homelab/start-db.sh`
  creates/starts it and generates credentials into `~/gta916/.mariadb.env`
  (mode 600, outside repo).
- oxmysql connection string added to the Enhanced profile's
  `server.cfg.local`. Database `gta916`, user `qbcore` verified with a
  live query.
- Enhanced server restarted after laptop reboot - clean boot, health
  endpoint OK. Client side now installed (GTA V Enhanced + FiveM Enhanced
  client, Cfx sign-in works). Remaining Phase 1: in-game connect test,
  QBCore deployment.

## 2026-07-28 - Formalized three persistence layers

- Pipeline doc now defines transactional (MariaDB OLTP), operational
  (Postgres `ops` schema: append-only events, health snapshots, live-state
  views) and analytical (Postgres `analytics` schema: derived materialized
  views only) layers with one-way flow and per-layer retention.
- Write rules: only collector/poller/ETL write `ops`; `analytics` is
  refresh-only. Grafana reads `ops` for health/alerting, `analytics` for
  KPIs.

## 2026-07-28 - Designed analytics pipeline

- New `docs/setup/analytics-pipeline.md`: append-only events table in
  Postgres (partitioned, JSONB), fed by health polling (v0), gameplay
  events from [gta916] resources via a small collector (v1, Phase 2), and
  Tebex webhooks + MariaDB ETL (v2, Phase 3). Materialized views derive
  all KPIs; Grafana for dashboards and launch-week down-alerting.
- Whitepaper data-architecture section links to it.

## 2026-07-28 - Decided two-store data architecture

- Whitepaper now specifies: MariaDB for gameplay OLTP (QBCore/oxmysql
  compatibility constraint), PostgreSQL (AlloyDB-style) as a separate
  analytics/telemetry store from Phase 2.
- Rationale: no single dialect fits both; Postgres on the game side would
  mean permanently forking QBCore's data layer, while analytics is where
  Postgres capabilities actually pay off.

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
