# GTA916: Roadmap & Whitepaper

Version 1.0 - 2026-07-28
Owner: GTA916 project
Status: living document - revise at each phase gate

---

## 1. Executive summary

GTA916 is a Sacramento (916)-themed GTA roleplay server built on FiveM for
GTAV Enhanced, paired with owned media channels (faceless YouTube, streaming,
marketing) that funnel players to the server and diversify revenue. The
thesis: the GTA6-era attention wave is lifting the entire GTA ecosystem, few
servers own a regional identity, and almost nobody is live on the brand-new
Enhanced platform yet. GTA916 aims to be the definitive 916-area server
before the wave peaks.

Target: public soft launch by mid-October 2026. End state: a
community-operated server whose store revenue covers costs plus profit,
fed by a self-reinforcing content flywheel, with the owner in a product
direction role rather than daily operations.

## 2. Market context

- **GTA6 halo.** Interest in everything GTA is at a cyclical high. GTA RP
  (FiveM) historically captures a large share of that attention through
  streamers and YouTube clips.
- **Enhanced early access (since 2026-07-21).** Cfx.re rebuilt the platform
  for GTAV Enhanced: client-server sync (lower latency), up to 50% lower
  server RAM, .NET 10 / NodeJS 26 runtimes. Most established servers are
  waiting for Asset Escrow before migrating. That gap is GTA916's window:
  early Enhanced servers get novelty, listing visibility, and content
  material competitors cannot produce yet.
- **Regional identity is under-served.** Thousands of generic Los Santos RP
  servers exist; few own a real-world region. "916" gives the server a
  built-in community (Sacramento locals and diaspora), a content angle, and
  a moat that generic servers cannot copy.

## 3. Product architecture

Three separated concerns (one repo, one-way data flow):

1. **Server stack** - FiveM for GTAV Enhanced (Cfx Server + txAdmin v9),
   QBCore framework (fork: formula38/qb-core), custom resources under
   `resources/[gta916]/`. Runs on homelab now; moves to dedicated hosting
   before public launch.
2. **Content channels** - faceless YouTube, streaming, marketing materials
   (`channels/`). They consume footage and stories *from* the server; the
   server never depends on them.
3. **Growth & revenue** - Tebex store (the only Cfx-authorized monetization
   path), channel monetization, and community funnels (Discord).

Key technical documents: `docs/setup/fivem-foundation.md`,
`docs/setup/gtav-enhanced.md`, `docs/setup/qbcore-stack.md`,
`docs/policy/monetization-readiness.md`, `docs/dev-workflow.md`.

## 4. Roadmap

Phase gates are checkpoints: do not advance until the exit criteria are met.
Dates assume ~5-10 focused hours/week.

### Phase 1 - Foundation (July 21 - Aug 15) - IN PROGRESS

Goal: a stable, private Enhanced server with the full framework stack.

- [x] Repo, ops scripts, docs, secret hygiene (2026-07-27)
- [x] Legacy server boots, default resources wired (2026-07-27)
- [x] Migration to GTAV Enhanced: Cfx Server b98-ea + txAdmin v9 (2026-07-28)
- [x] `gta916-core` running on Enhanced with status/health endpoints
- [ ] First in-game connect with the Enhanced client (`/gta916ping`)
- [ ] MySQL/MariaDB installed and reachable for QBCore
- [ ] QBCore deployed on Enhanced, full smoke test pass
- [ ] Weekly artifact-update habit established (Enhanced hotfixes)

**Exit criteria:** a test player can connect, spawn, and use one QBCore
system (job or money) with zero console errors for a 30-minute session.

### Phase 2 - World building (Aug 15 - Sep 30)

Goal: the 916 identity exists in-game and the server survives strangers.

- [ ] Character creation, jobs, economy tuned (QBCore configs)
- [ ] 3-5 signature 916 elements: Sacramento-flavored jobs, locations,
      street names, local references (all assets Enhanced-compatible;
      convert legacy assets with Alchemist)
- [ ] Admin structure: txAdmin roles, rules doc, report flow
- [ ] Discord server with whitelist/onboarding flow
- [ ] Closed alpha: 5-15 invited players, at least 4 test sessions
- [ ] Backup automation (database + txData) and restore drill
- [ ] Hosting decision: keep homelab (port forward, UPS, static IP/DDNS) or
      move to a dedicated box/VPS - decide by Sep 15
- [ ] Content channels publishing weekly from build/alpha footage
- [ ] Tebex store built in draft (cosmetics, priority queue, supporter
      perks - nothing pay-to-win), NOT launched

**Exit criteria:** 10 concurrent alpha players for a full evening with no
crash and no game-breaking exploit; moderation handled a real incident.

### Phase 3 - Soft launch (Oct 1 - mid-Oct)

Goal: public, listed, monetized, growing.

- [ ] Remove `sv_master1 ""` - server appears on the public list
- [ ] Port forwarding / hosting cutover complete, connection tested from
      outside the LAN
- [ ] Launch trailer + channel announcement synchronized with listing
- [ ] Tebex store live; monetization-readiness checklist re-verified
- [ ] Launch-week presence: owner online during peak hours daily
- [ ] Watch Asset Escrow arrival on Enhanced - unlocks marketplace assets

**Exit criteria:** 7 consecutive days public with >20 unique players, store
processing real transactions, moderation keeping up.

### Phase 4 - Flywheel (post-launch)

Goal: reduce owner ops to <5 hrs/week; grow revenue.

- [ ] 2-3 moderators recruited from the community
- [ ] Weekly content cadence: one in-game event/update + one channel drop
      per week, each feeding the other
- [ ] Revenue review monthly: store SKUs, channel monetization, costs
- [ ] Quarterly roadmap revisions to this document

**End state definition:** the server runs a full week without owner
intervention; store revenue >= hosting costs + margin; channels deliver a
steady stream of new players; owner's role is product direction.

## 5. Operating model (admin day-to-day by phase)

| Phase | Daily | Weekly |
| --- | --- | --- |
| 1 - Foundation | 30-90 min build sessions in txAdmin + editor | Artifact update check; changelog entries |
| 2 - World building | Build + alpha session hosting | Alpha retro, backup verify, one content drop |
| 3 - Soft launch | 15-min morning log/report check; evening peak presence | Update drop + announcement; store review |
| 4 - Flywheel | Delegated to mods; owner checks dashboards | Product direction, event planning, revenue review |

Standing rules:

- Every change is committed to the repo and noted in `CHANGELOG.md`.
- Nothing ships to the live server without passing
  `docs/setup/private-smoke-tests.md`.
- Secrets never enter the repo (`server.cfg.local` + pre-commit scan).
- Monetization stays within Cfx/Tebex policy
  (`docs/policy/monetization-readiness.md`) - no pay-to-win, ever.

## 6. Revenue model

Streams, in order of expected activation:

1. **Tebex store (Phase 3+):** cosmetics, priority queue, supporter tiers.
   Industry norm for a healthy mid-size RP server is store revenue covering
   hosting several times over; treat first-month revenue as validation, not
   income.
2. **Channel monetization (Phase 3+):** YouTube ads/shorts from faceless
   channel; streaming subs/donations once audience justifies live schedule.
3. **Sponsorships/partnerships (Phase 4):** local 916 businesses or creators
   once the regional audience is proven.

Costs to plan for: dedicated hosting (~$20-60/mo if leaving homelab),
domain/Discord boosts, eventual paid assets (post-Asset-Escrow), moderator
perks.

## 7. Risks and mitigations

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| Enhanced early-access instability | High (expected) | Weekly hotfix updates; legacy runtime kept as fallback; quirks documented in `docs/setup/gtav-enhanced.md` |
| QBCore incompatibility on Enhanced | Medium | Backward compat is officially supported; validate early in Phase 1; fall back to minimal custom framework for launch if blocked |
| Homelab reliability (sleep/power/ISP) | High if not addressed | Phase 2 hosting decision; UPS; disable sleep; move to dedicated hosting before launch |
| Owner burnout (solo operator) | Medium | Phase gates limit scope; delegate moderation in Phase 4; content batching |
| GTA6 launch pulls attention away | Unknown timing | The regional identity and community outlast platform cycles; channels can pivot to GTA6 content while the server community persists |
| Policy/compliance mistake | Low | Tebex-only monetization; `docs/policy/monetization-readiness.md` checklist before any store change |

## 8. KPIs

Track from Phase 2 onward (weekly snapshot in the changelog or a sheet):

- Server: unique players/week, peak concurrent, average session length,
  crash count, D7 return rate
- Community: Discord members, whitelist applications, mod-handled incidents
- Content: videos published, views, click-throughs to Discord
- Revenue: store transactions, revenue vs. costs

North-star metric: **weekly returning players** - everything else feeds it.

## 9. Document control

- Update this document at each phase gate (exit criteria review).
- Log all operational changes in `CHANGELOG.md` as they happen.
- Strategy details for audiences/channels live in
  `docs/strategy/gta916-audience-and-income.md`; this whitepaper is the
  umbrella.
