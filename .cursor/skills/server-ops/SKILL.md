---
name: server-ops
description: Operate the GTA916 FiveM homelab server - start, stop, check status, update artifacts, wire profiles, read logs, and troubleshoot known failures. Use when the user asks to start/stop/restart the server, says the server is down or erroring, wants a txAdmin PIN, or asks to update the server build.
---

# GTA916 Server Operations

Runtime base: `~/gta916`. Enhanced (primary): `server-enhanced/` +
`txData-enhanced/`. Legacy (fallback): `server/` + `txData/`. Both use ports
30120 (game) / 40120 (txAdmin) - only one runs at a time.

## Status check

```bash
ss -tlnp | rg "30120|40120"                                  # listening?
curl -s http://localhost:30120/gta916-core/health            # health JSON
pgrep -fa "server-enhanced/alpine" | rg -v "zsh|rg"          # processes
```

Console log: read the terminal file of the shell running the server, or
`~/gta916/txData-enhanced/default/logs/`. Strip ANSI when grepping:
`sed 's/\x1b\[[0-9;]*m//g'`.

## Start / stop

- Start (persistent): run `ops/homelab/start-server-enhanced.sh` as a
  **backgrounded shell task** (`block_until_ms: 0`). A nohup from a normal
  shell dies when the shell exits - the panel goes down minutes later.
- First boot prints a txAdmin registration PIN (expires ~5 min). Extract:
  `rg -o "┃ +[0-9]{4} +┃" <logfile>`. If expired, restart the server for a
  fresh one.
- Stop: find the txAdmin parent with `pgrep -f "server-enhanced/alpine"`
  and `kill` it. CAUTION: never `pkill -f` a pattern that appears in your
  own command line - the shell kills itself.
- Restart game server only (re-execs server.cfg, txAdmin auto-recovers):
  kill the child process whose cmdline contains `txAdminServerMode`.

## Update to a new Enhanced build

```bash
rm -rf ~/gta916/server-enhanced && ops/homelab/bootstrap-enhanced.sh
```

The download is resumable; the server logs an update notice on startup when
a newer build exists. Add a CHANGELOG.md entry with the new build id.

## Wire a profile (after first txAdmin boot)

```bash
ops/homelab/wire-profile.sh ~/gta916 default txData-enhanced
```

Installs server.cfg from template, secrets example, and symlinks
cfx-server-data + `[gta916]` resources. License key lives only in
`txData-enhanced/default/server.cfg.local`.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| `E5110` on boot | Profile folder pre-existed without config.json - delete it, let txAdmin create it |
| `Failed to generate cache for set: resource.rpf` | Resource started dynamically; `ensure` it at boot in server.cfg |
| "server list query returned an error" | Expected in private mode behind NAT; `sv_master1 ""` silences it |
| Port already in use | The other edition's server is running - stop it first |
| Panel unreachable right after PIN printed | Server process died with its parent shell - restart as backgrounded task |
| More Enhanced quirks | `docs/setup/gtav-enhanced.md` |

After any operational incident or change, add a `CHANGELOG.md` entry.
