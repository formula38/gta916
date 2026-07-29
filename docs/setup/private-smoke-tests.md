# Private Smoke Tests

Use this checklist after initial setup and after every significant update.

## A) txAdmin and runtime

- [ ] server process (`Cfx Server` on Enhanced, `FXServer` on legacy) starts without fatal errors.
- [ ] txAdmin is reachable on `http://<host>:40120`.
- [ ] server profile loads expected config.
- [ ] (Enhanced) startup log shows no update prompt, or note the newer build for the next artifact refresh.

## B) Network checks

- [ ] port `30120` TCP/UDP reachable from LAN test client.
- [ ] port `40120` reachable only from trusted admin network.

## C) QBCore and resources

- [ ] `qb-core` starts successfully.
- [ ] `gta916-core` starts successfully.
- [ ] status page loads at `http://localhost:30120/gta916-core/` (human-readable dashboard).
- [ ] health JSON responds at `http://localhost:30120/gta916-core/health`.
- [ ] no repeating server console errors for 10+ minutes idle.

## D) Player flow

- [ ] test player can connect and spawn (Enhanced runtime requires the separate FiveM for GTAV Enhanced client + GTA V Enhanced install).
- [ ] at least one GTA916 custom command/event responds.
- [ ] disconnect/reconnect path works cleanly.

## E) Regression checks after updates

- [ ] restart server and confirm resources auto-start in correct order.
- [ ] run one event/interaction that exercises DB writes (if enabled).
- [ ] verify no new warnings around permissions/exports/dependencies.

## F) Logging evidence

Capture and store:

- server startup log snippet
- txAdmin status screenshot
- notes for any warnings and mitigation decisions
