# Open items — no silent restoration

## SharedMedia arrows and Party/Raid role artwork — in-game verification

- Confirm both new Unit Frames controls fit the options page on Retail/Forever.
- Enable EUI target arrows, select - Arrow Glow and confirm inward direction,
  native scale/color/position and updates after target changes and pool reuse.
- Switch back to native artwork and test missing registered media fallback.
- Enable FafnyirMedia role artwork in Party/Raid; check Tank/Healer/DPS,
  native role filters, combat visibility, size and offsets. Disable it and
  verify native artwork returns. Main unit frames and extra frames stay native.
- Test reload persistence, global settings transfer and combat taint in game.

## v1.1.6 diagnostics in-game verification

- Confirm the About-page **Copy Diagnostics** row is aligned and visible.
- Confirm the native copy popup selects/copies the complete report on Retail
  and Forever.
- Review a copied report to confirm the live client, dependency versions and
  enabled feature states match the test installation.

## Forever fog toggle hidden in v1.1.5

- User decision, 2026-09-26: the Forever-only **Volumetric Fog** toggle is
  hidden for v1.1.5.
- Blizzard now overrides the `volumeFog 0` console setting after it is applied;
  players report that fog changes for only a moment and then returns. The
  former control was therefore misleading even though FafnyirTools persisted
  and reapplied its saved choice.
- The implementation is dormant rather than presenting a nonfunctional
  option. Reconsider it only if Blizzard exposes a supported, persistent fog
  setting in a later client build.

## WoW Forever beta validation

- Do not treat the Forever beta package as fully testable until Blizzard fixes
  SavedVariables persistence and EllesmereUI removes `FOREVER_SV_BUG`.
- Then verify sidebar/options registration, Unit Frame sources, settings
  import/reset, Target auras, XP/Rested/Quest overlays, Resting, action-bar
  behavior, bags/bank/currencies/tooltips and companion summoning in game.
- The package must remain separate from the Retail installation and release.

## Resolved in consolidated v1.1.2

Persistent Companion Pet, QoL, companion defaults/events/TOC/options, prior
release history and companion credits are restored. The prior source credited
raine for the original WeakAura; that existing attribution is retained (not a
new independent author verification). Eiya credit is retained as well.

Options are consolidated to seven pages with Resting under Unit Frames,
XP & Progression and Layouts. This preserves later Aura/source and Action Bars
grouping. Legacy Quest XP setting names now migrate without overwriting newer
saved values. These changes are offline-tested; the user confirmed “All fixed.” on 2026-08-27. See CURRENT_STATE.md for the exact build and limits of this report.

## 3. Broader inventory functionality

Historical request covered searching all characters, bags, banks, mail, auctions, warband/guild storage, gold/currencies. Current code scans bags, personal bank and currency list and aggregates cached locations; dedicated mail/auction/warband/guild scanners and a search UI are not present. Existing data tables/tooltip labels are not implementation. Keep as a future scope decision; do not advertise complete live tracking.

Roadmap decision, 2026-09-26: full inventory search is deferred to v2.0.0.
Start with reliable cached character bags and personal banks, asynchronous item
metadata, result sorting, and cache-age reporting. Mail, auction, Warband, and
guild scanners remain separate API-validation work and are not automatically
included merely because the v2.0.0 search project begins.

## 4. Focus aura styling

Focus source control exists. Custom Focus aura containers do not. Treat as a separate feature request if desired.

## 5. Release assurance / backup

Offline mocks do not verify real EUI render layers, combat taint, or every retail API behavior. Follow TESTING.md for releases. No upstream/remote repository or off-machine backup has been configured; local Git and the supplied snapshot only protect against local editing mistakes. Publishing/backing up to a remote requires a separate destination/authorization.

## 6. Historical coverage limits

The main chat was recovered as 204 turns spanning Aug 5–27 from cached paginated reads, including a terminal oldest page and refreshed newest page. Identified local development task texts were consolidated; mixed-topic Website/WoW material is selectively indexed. Binary attachments are not a complete archive, and unrelated chats were not exhaustively read for incidental mentions. No claim is made that inaccessible/deleted/other-account chats have been merged. Use source IDs in HISTORY.md to revisit any missing context.

## 7. Reset / Disable All redesign

The first v1.1.3 implementation was withdrawn after repeated disconnects in the
test build. Revisit only after the rollback build is stable. Avoid synchronizing
all source ownership and refreshing every feature inside one live options reset
callback; stage changes for the next login instead.
