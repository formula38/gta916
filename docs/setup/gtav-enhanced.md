# FiveM for GTAV Enhanced (Early Access)

GTA916 now targets **FiveM for GTAV Enhanced**, which entered early access on
**July 21, 2026**. This doc covers what changed versus the legacy stack, how to
run the Enhanced server on the homelab, and what to do on the client side.

Status: early access. Expect bugs, weekly hotfixes, and missing features. Cfx
themselves say most production servers will wait for Asset Escrow before
migrating - which is exactly why being on Enhanced NOW is a content and
positioning advantage for GTA916.

## Why this matters for the mid-October goal

- Enhanced is where Cfx is investing (rebuilt networking, .NET 10, NodeJS 26,
  up to 50% less server RAM). It is also the groundwork they would need for
  any future GTA6-era support.
- Few servers run Enhanced yet. "GTA916 on GTAV Enhanced" is a differentiator
  for the server listing and for channel content (setup guides, early-access
  bug/fix videos, before/after graphics comparisons).
- By mid-October, early access will have ~3 months of hotfixes behind it, and
  our stack will already be validated on it.

## Server side: parallel Enhanced runtime

The Enhanced server component is called **Cfx Server**. It is a separate
download from legacy FXServer artifacts, published on the official
[Server Download page](https://docs.fivem.net/docs/server-download/) (switch
Platform to "FiveM for GTAV Enhanced"). The Linux archive is
`cfx-server_linux_x64.tar.xz`; txAdmin is still embedded, and Linux builds
still use the Alpine rootfs, so homelab requirements are unchanged.

We keep the legacy runtime intact and add a parallel one:

```
~/gta916/
  server/             # legacy FXServer (kept as fallback)
  txData/             # legacy txAdmin data (kept)
  server-enhanced/    # Cfx Server (Enhanced)
  txData-enhanced/    # Enhanced txAdmin data (own profile + PIN setup)
  cfx-server-data/    # shared default resources (works on both)
```

Setup flow (mirrors the legacy three-script flow):

```bash
./ops/homelab/bootstrap-enhanced.sh          # download + extract Cfx Server
./ops/homelab/start-server-enhanced.sh       # first boot, prints txAdmin PIN
# open http://localhost:40120, enter PIN, link Cfx.re account, pick the
# 'CFX Default' recipe (or skip deployment) - same as the legacy setup
./ops/homelab/wire-profile.sh ~/gta916 default txData-enhanced
# fill ~/gta916/txData-enhanced/default/server.cfg.local with your license key
# then restart from txAdmin
```

Both runtimes use ports 30120/40120, so only run one at a time. Stop the
legacy server before starting the Enhanced one.

Note: your existing `sv_licenseKey` from Keymaster works the same way on
Enhanced - reuse it in the new profile's `server.cfg.local`.

## What changed (relevant subset)

Full list: [What's Changed in FiveM for GTAV Enhanced](https://docs.fivem.net/docs/developers/legacy-vs-enhanced/).
What actually affects GTA916:

| Change | Impact on us |
| --- | --- |
| Scripts are backward compatible (Lua/JS/C# natives) | `gta916-core`, cfx-server-data, and QBCore are expected to work - validate via smoke tests |
| `endpoint_add_tcp/udp` accept a single endpoint only | Fine - our config already uses one each |
| OneSync big mode is the only mode | Nothing to configure; non-big mode is gone |
| Pure mode always on | No client graphics mods during early access |
| Only the latest gamebuild supported, loaded by default | Do not pin `sv_enforceGameBuild` unless you want base-game-only (`1`) |
| Dev tools require `sv_devMode true` server-side | Enable for private testing; caps the server at 8 slots (fine for us) |
| Asset Escrow not implemented yet | Blocks paid/escrowed marketplace assets - irrelevant until Phase 2 purchases |
| Mono replaced by .NET 10 | Only matters if we ever write C# resources |
| Key-value DB files need migration | We have no KVP data worth migrating - fresh profile |

Custom streamed assets (cars, maps, clothing) must be converted with Cfx's
[Alchemist tool](https://docs.fivem.net/docs/) before they work on Enhanced.
We stream no custom assets yet, so nothing to convert today - but every asset
we buy or build from now on must be Enhanced-compatible.

## Client side (your gaming setup)

1. Install **GTA V Enhanced** on Windows (Rockstar, Steam, or Epic - your
   Epic download works).
2. Install the separate **FiveM for GTAV Enhanced client** from
   [fivem.net](https://fivem.net) - it is a different launcher from legacy
   FiveM, and both can coexist. On first run it asks you to locate the GTA V
   Enhanced install and sign in with your Cfx.re account.
3. Connect the same way as before: `F8` console, `connect localhost:30120`.

## Known early-access quirks we hit (and fixes)

- **`Failed to generate cache for set: resource.rpf` when mapmanager starts a
  map**: on Enhanced, resources started dynamically after boot can fail cache
  generation. Fix: `ensure fivem-map-hipster` in `server.cfg` before
  `basic-gamemode` so the map starts at boot (already in our template). This
  also pins the freeroam map instead of letting mapmanager pick randomly.
- **`EnableEnhancedHostSupport: This native is deprecated`** warning from
  `sessionmanager`: harmless, P2P host support no longer exists on Enhanced.
- **Duplicate `chat` resource warning**: harmless, comes from cfx-server-data
  shipping chat in two category folders.

## Early access expectations

- Hotfixes ship frequently (3 in the first week). The server checks for
  updates on startup and tells you when a new build is available; re-run
  `bootstrap-enhanced.sh` after deleting `~/gta916/server-enhanced` (or just
  the binaries) to pick up a new build.
- Report/track bugs on the
  [citizenfx GitHub Discussions](https://github.com/citizenfx/rfc/discussions)
  board - engaging there early also builds credibility for the brand.
- If Enhanced blocks progress on QBCore work, the legacy runtime is still on
  disk; the only thing you lose by switching back temporarily is the client
  (GTA V Legacy would need reinstalling).

## Runway to mid-October

1. Now: Enhanced server boots, default resources + `gta916-core` validated.
2. August: QBCore deployed and smoke-tested on Enhanced; start recording
   early-access setup content for the channels.
3. September: jobs/economy customization, 916-flavored content, Tebex store
   prep (watch for Asset Escrow arriving).
4. Early October: port forwarding, public listing, soft launch to a small
   community; content channels announce.
