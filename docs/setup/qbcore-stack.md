# QBCore Stack Strategy

This guide describes how GTA916 should use QBCore while keeping upgradeability with your fork.

## Goals

- keep `qb-core/` as close to upstream as practical
- isolate GTA916 custom logic in separate resources
- avoid hard-forking business logic into framework core unless required

## Recommended architecture

- `qb-core/` (fork): minimal patches, upstream-compatible maintenance
- `resources/[gta916]/...`: GTA916 gameplay/features/commands/integrations
- server config controls start order and environment values

## Recipe and dependencies

For first setup:

1. Deploy txAdmin QBCore recipe (or CFX default then migrate).
2. Confirm DB connector used by selected recipe (`oxmysql` is common).
3. Verify core dependencies start before GTA916 resources.

Typical start order pattern:

1. FiveM base/default resources
2. database/lib dependencies
3. `qb-core`
4. framework-adjacent resources
5. `gta916-core` and other GTA916 custom resources

## Fork maintenance workflow

- Keep a local branch for GTA916 changes.
- Pull upstream changes into a tracking branch regularly.
- Merge upstream into GTA916 branch in small batches.
- Validate with smoke tests before promoting to production host.

## What should live in `qb-core` vs custom resources

Keep in `qb-core` only:

- compatibility fixes tightly coupled to framework internals
- unavoidable core-level bug fixes pending upstream

Put in GTA916 custom resources:

- commands, jobs, events, location-specific content
- telemetry hooks for clips/content signals
- economy/business logic specific to GTA916

## Conflict prevention

- Document each direct `qb-core` patch in commit messages.
- Prefer exports/events over direct core file edits.
- Do not duplicate identifiers across resources.
