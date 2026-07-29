---
name: smoke-test
description: Run the GTA916 private smoke test checklist against the running server and report pass/fail with evidence. Use after server setup, artifact updates, config changes, or when the user asks to verify, validate, or smoke test the server.
---

# GTA916 Smoke Test

Checklist source of truth: `docs/setup/private-smoke-tests.md`. This skill
automates the server-side checks; player-flow checks need the user in-game.

## Automated checks (run all, report a table)

```bash
# A) runtime up and listening
ss -tlnp | rg "30120|40120"
curl -s -o /dev/null -w "%{http_code}" http://localhost:40120

# C) resources and status endpoints
curl -s http://localhost:30120/gta916-core/health         # expect JSON with resourceCount
curl -s -o /dev/null -w "%{http_code}" http://localhost:30120/gta916-core/   # expect 200
```

Log scan (strip ANSI first). Fail on: `error`, `Failed`, `Couldn't find
resource`, `No such command`. Known-harmless on Enhanced:
`EnableEnhancedHostSupport ... deprecated`, duplicate `chat` resource
warning, `sv_master1` list messages.

```bash
sed 's/\x1b\[[0-9;]*m//g' <console-log> | rg -i "error|failed|couldn't|no such command"
```

Also confirm expected startup lines: `Started map fivem-map-hipster`,
`Started resource gta916-core`, `server initialized`.

## Manual checks (ask the user)

- Connect with the FiveM Enhanced client: `connect localhost:30120`
- Spawn works, `/gta916ping` returns pong in chat
- Disconnect/reconnect is clean
- (Once QBCore is deployed) one job/money interaction works

## Report format

| Check | Result | Evidence |
| --- | --- | --- |
| txAdmin reachable | PASS | HTTP 200 on :40120 |
| ... | ... | ... |

If everything passes, record it in `CHANGELOG.md` (date, build id, result).
If something fails, diagnose before declaring the server healthy - consult
the troubleshooting table in the `server-ops` skill.
