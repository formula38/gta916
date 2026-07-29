---
name: changelog-entry
description: Add an operational changelog entry to the GTA916 CHANGELOG.md in the established format. Use at the end of any working session that changed the server, config, resources, or docs, or when the user asks to log or record what was done.
---

# Changelog Entry

File: `CHANGELOG.md` (repo root). Newest entry goes directly under the
`---` separator line, above the previous newest entry.

## Format

```markdown
## YYYY-MM-DD - short imperative title

- what changed (concrete: files, builds, settings)
- why / context (one line)
- follow-ups or gotchas a future admin needs (optional)
```

## Rules

- One entry per working session or meaningful change; merge small same-day
  items into one entry rather than stacking near-empty entries.
- Name concrete artifacts: build ids (e.g. "Cfx Server b98-ea"), resource
  names, config keys, script names.
- Record smoke-test outcomes and unresolved issues explicitly - the
  changelog doubles as the operational memory for future moderators.
- Never include secrets (license keys, tokens, connection strings).
- Commit the changelog together with the change it describes.
