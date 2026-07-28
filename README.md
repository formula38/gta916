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

1. Read `docs/setup/fivem-foundation.md`.
2. `./ops/homelab/bootstrap.sh` — scaffolds `~/gta916` and downloads the recommended FXServer build.
3. `./ops/homelab/start-server.sh` — first boot; open `http://localhost:40120`, enter the console PIN, link your Cfx.re account.
4. `./ops/homelab/wire-profile.sh` — installs `server.cfg` + `server.cfg.local` and symlinks repo resources into the profile.
5. Put your real `sv_licenseKey` in `~/gta916/txData/default/server.cfg.local` (gitignored), then restart the server.
6. Run the checks in `docs/setup/private-smoke-tests.md`.

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
