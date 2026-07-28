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
2. Run `ops/homelab/bootstrap.sh` to scaffold local FiveM runtime directories.
3. Follow txAdmin first-run setup and apply your server key.
4. Use `ops/homelab/server.cfg.template` as a starting point for `server.cfg`.
5. Start with the CFX default or QBCore recipe in txAdmin, then add `gta916-core`.
6. Run the checks in `docs/setup/private-smoke-tests.md`.

## Notes

- Do not commit secrets (license keys, Tebex secrets, database passwords).
- Use `server.cfg.local` for real keys/secrets and keep template files sanitized.
- Keep `qb-core/` aligned with upstream, and place GTA916-specific behavior in custom resources when possible.
