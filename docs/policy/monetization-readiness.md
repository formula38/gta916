# Monetization Readiness Guardrails

This document defines policy guardrails before GTA916 enables paid perks.

## Core principle

For FiveM ecosystems, use the approved monetization route (Tebex integration) and avoid side channels for paid in-game privileges.

## Phase split

- Phase 1 (current): no paid products live; focus on server stability and audience growth.
- Phase 2: enable monetization only after compliance review and private stability checks.

## Required controls before launch

1. Store and server linkage completed through approved Tebex/FiveM integration flow.
2. Public terms for players (refund/support/perk definitions) published.
3. Clear disclaimer language that server is community-run and not Rockstar-endorsed.
4. Package definitions reviewed to avoid restricted content patterns.



## Do-not-ship list (until reviewed)

- chance-based paid rewards (loot-box style)
- paid gambling mechanics with real currency value
- unclear or misleading package claims
- secret/admin-only manual grant systems that bypass store audit trail



## Configuration and secret handling

- Never commit license keys or Tebex secrets.
- Keep `sv_tebexSecret` and related credentials in host-local config only.
- Rotate secrets after any accidental exposure.



## Compliance gate checklist

Before enabling any paid package, confirm:

- legal/policy review complete for current platform terms
- package commands tested on staging/private environment
- rollback process exists for failed package delivery
- support contact path is visible to users



## Change management

- Record monetization config changes with date and owner.
- Review policies quarterly or when platform terms change.

