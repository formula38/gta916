# Development Workflow

This doc explains which files to edit (and when), how a change travels from your editor to the running server, and what the CI/CD picture looks like today.

## File map: what to edit, when, and why

### Edit daily (feature work)

| Path | What it is | Why you'd edit it |
| --- | --- | --- |
| `resources/[gta916]/gta916-core/` | Your custom resource code (Lua) | All GTA916 gameplay features, commands, events. This is where new work goes by default. |
| `resources/[gta916]/` (new folders) | Additional custom resources | When a feature is big enough to deserve its own resource (new job system, phone integration, etc.). |

### Edit occasionally (configuration)

| Path | What it is | Why you'd edit it |
| --- | --- | --- |
| `ops/homelab/server.cfg.template` | Sanitized baseline server config | Changing hostname, max players, resource start order. Never put real keys here. |
| `~/gta916/txData/default/server.cfg.local` | Runtime-only secrets overlay (NOT in repo) | Rotating your license key, adding the Tebex secret in Phase 2, DB credentials. |
| `qb-core/` (submodule) | Your QBCore fork | Only for framework-level fixes that cannot live in a custom resource. Prefer custom resources; see `docs/setup/qbcore-stack.md`. |

### Edit rarely (infrastructure)

| Path | What it is | Why you'd edit it |
| --- | --- | --- |
| `ops/homelab/bootstrap.sh` | Runtime scaffold + artifact download | When FiveM changes its artifact listing or you change the runtime layout. |
| `ops/homelab/wire-profile.sh` | Installs configs + resource symlink into a txAdmin profile | When the profile layout or symlink strategy changes. |
| `ops/homelab/start-server.sh` | Server launcher with correct env vars | When txAdmin changes its startup convention (it deprecated `+set serverProfile` in v8). |
| `scripts/security/` | Pre-commit secret scanning | Adding new secret patterns to block. |
| `docs/` | Setup, policy, strategy docs | Keeping docs honest as the system evolves. |
| `channels/` | Content-ops playbooks | Refining YouTube/streaming/marketing workflows. These never touch the server runtime. |

## How a code change reaches the running server

The runtime resources folder is a **symlink** into this repo, so there is no copy/deploy step for resource code:

1. Edit files in `resources/[gta916]/gta916-core/`.
2. In the txAdmin console (or F8 client console): `restart gta916-core`.
3. The change is live. No server reboot needed for script changes.

Config changes (`server.cfg`, `server.cfg.local`) require a full server restart from txAdmin.

Engine upgrades (new FXServer build) are a re-run of `bootstrap.sh` after deleting or renaming `~/gta916/server` — your data in `~/gta916/txData` is untouched. The installed build number is recorded in `~/gta916/server/ARTIFACT_VERSION`.

## CI/CD: current state

There is no remote CI pipeline yet. The current safety net has three layers:

1. **Local pre-commit hook** (`scripts/security/pre-commit-secret-scan.sh`, installed via `scripts/security/install-hooks.sh`): blocks commits containing likely secrets (Cfx keys, Tebex secrets, GitHub tokens, private keys). Uses `gitleaks` when installed, otherwise a focused regex fallback.
2. **GitHub push protection**: the remote rejects pushes containing detected secrets (this has already saved us once — it blocked a real Cfx key).
3. **Manual review**: you are the release gate. Nothing deploys automatically.

Deployment is manual by design in Phase 1:

```
edit -> commit (hook scans) -> push (GitHub scans) -> pull on homelab host -> restart resource/server
```

The `qb-core` submodule has its own flow: work happens in the fork's own repo/branches, and this repo pins a specific commit of it. To pick up fork changes here: `cd qb-core && git pull`, then commit the updated submodule pointer in this repo.

## CI/CD: sensible next steps (when ready)

Not built yet, listed in rough priority order:

- GitHub Action running `gitleaks` on every push (backstop for the local hook).
- Lua linting (`luacheck` or `lua-language-server`) on `resources/**` in CI.
- A deploy script or Action that SSHes to the homelab host, pulls `main`, and restarts affected resources.
- Artifact version pinning checks (alert when the pinned FXServer build falls behind the recommended one).
