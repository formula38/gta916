# Analytics Pipeline (Collect → Populate → Persist → View)

Design for the PostgreSQL analytics store defined in the whitepaper's
"Data architecture" section. Gameplay stays on MariaDB; everything here is
read-only with respect to the game and can fail without touching gameplay.

## Principles

- **Append-only source of truth.** Raw events are immutable; every report,
  dashboard, and KPI is derived and rebuildable from them.
- **One-way flow.** Game server emits; analytics consumes. The game never
  reads from the analytics store.
- **Boring over clever.** Cron + SQL before streaming frameworks. Upgrade
  only when a real bottleneck appears.

## Architecture

```
[gta916 resources] --events (HTTP JSON)--> [collector] --insert--> Postgres
[/gta916-core/health] --cron poll (1 min)-------------------------^
[MariaDB]           --nightly ETL snapshot------------------------^
[Tebex]             --webhooks (Phase 3)--------------------------^
                                                                   |
                              materialized views (refreshed hourly/daily)
                                                                   |
                                                            [Grafana]
```

## 1) Collect

### v0 - health polling (available now, no new code in-game)

Cron every minute:

```bash
curl -s http://localhost:30120/gta916-core/health \
  | psql gta916_analytics -c \
  "INSERT INTO health_snapshots (payload) VALUES ('$(cat)'::jsonb)"
```

Gives: concurrency series, uptime/restart detection, resource count drift.

### v1 - gameplay events (Phase 2 backbone)

`[gta916]` resources emit fire-and-forget JSON via `PerformHttpRequest` to a
local collector. Event taxonomy (start small, extend as needed):

| event_type | fired when | key payload fields |
| --- | --- | --- |
| `player_login` / `player_logout` | connect/disconnect | player_id, session_id |
| `money_txn` | any economy movement | player_id, amount, reason, balance_after |
| `job_event` | job start/complete/quit | player_id, job, action, payout |
| `admin_action` | kick/ban/warn | admin_id, target_id, action |

Collector: one small FastAPI (or Express) service on the homelab with a
single `POST /events` endpoint, shared-secret header auth, batched inserts.
Keep it dumb: validate shape, stamp `received_at`, insert. No business
logic in the collector - that belongs in SQL views.

### v2 - external sources (Phase 3)

- Tebex webhooks → `store_txn` events (revenue KPIs).
- Nightly ETL from MariaDB for stateful snapshots events can't express
  (net worth distribution, inventory aggregates): one cron `SELECT ... INTO`
  per aggregate.

## 2) Populate & persist (Postgres schema)

```sql
-- raw layer: append-only, partitioned by month
CREATE TABLE events (
  id           bigint GENERATED ALWAYS AS IDENTITY,
  event_type   text        NOT NULL,
  occurred_at  timestamptz NOT NULL,
  received_at  timestamptz NOT NULL DEFAULT now(),
  player_id    text,
  payload      jsonb       NOT NULL,
  PRIMARY KEY (id, occurred_at)
) PARTITION BY RANGE (occurred_at);

CREATE TABLE health_snapshots (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  captured_at timestamptz NOT NULL DEFAULT now(),
  payload     jsonb       NOT NULL
);

-- derived layer: materialized views, all rebuildable
CREATE MATERIALIZED VIEW daily_active_players AS
  SELECT occurred_at::date AS day, count(DISTINCT player_id) AS dap
  FROM events WHERE event_type = 'player_login' GROUP BY 1;

-- weekly returning players = the north-star KPI
CREATE MATERIALIZED VIEW weekly_returning_players AS
  WITH weekly AS (
    SELECT date_trunc('week', occurred_at) AS wk, player_id
    FROM events WHERE event_type = 'player_login' GROUP BY 1, 2)
  SELECT w.wk, count(*) FILTER (
    WHERE EXISTS (SELECT 1 FROM weekly p
                  WHERE p.player_id = w.player_id
                    AND p.wk = w.wk - interval '1 week')) AS returning
  FROM weekly w GROUP BY 1;
```

Refresh cadence: hourly for operational views, nightly for cohort/retention
views (`REFRESH MATERIALIZED VIEW`, driven by cron or pg_cron).

Retention & backup:

- Raw partitions kept 12 months, then dropped (revisit at scale).
- `pg_dump` nightly alongside the MariaDB/txData backups (same drill,
  Phase 2 backup checkbox covers both).

## 3) View (dashboards)

**Grafana** over Postgres. Rationale: free, homelab-native, handles both
business KPIs and server health, and its alerting covers launch-week needs
(alert when health polling misses N minutes = server down).

Initial dashboards:

1. **Server health** - concurrency (from health_snapshots), uptime,
   restart markers.
2. **Community KPIs** - DAP, weekly returning players (north star),
   session length distribution, D7 retention.
3. **Economy** - money supply over time, top sources/sinks, txn volume
   (catches exploits early: a money-supply spike is an alarm, not a graph).
4. **Revenue (Phase 3)** - store transactions vs. costs.

Metabase can be added later if non-technical collaborators need ad-hoc
exploration; don't run both from day one.

## Rollout mapping to roadmap phases

| Phase | Deliverable |
| --- | --- |
| 1 (now) | Nothing required. Optionally start v0 health polling into a local Postgres. |
| 2 | Postgres + collector + `player_login/logout` + `money_txn` events; Grafana with dashboards 1-2; backups in the restore drill. |
| 3 | Tebex webhooks, economy dashboard alerts, launch-week down-alerting. |
| 4 | Cohort/retention views feed the monthly revenue review; consider AlloyDB Omni if analytical queries outgrow vanilla Postgres. |
