# Open items — no silent restoration

## WoW Forever beta validation

- Do not treat the Forever beta package as fully testable until Blizzard fixes
  SavedVariables persistence and EllesmereUI removes `FOREVER_SV_BUG`.
- Then verify sidebar/options registration, Unit Frame sources, settings
  import/reset, XP/Rested/Quest overlays, action-bar
  behavior, bags/bank/currencies/tooltips and companion summoning in game.
- The package must remain separate from the Retail installation and release.

## Resolved in consolidated v1.1.2

Persistent Companion Pet, QoL, companion defaults/events/TOC/options, prior
release history and companion credits are restored. The prior source credited
raine for the original WeakAura; that existing attribution is retained (not a
new independent author verification). Eiya credit is retained as well.

Options were consolidated to seven pages in v1.1.2. Unit Frame Sources, Aura
Skins, and Resting were retired in v1.1.4 when EllesmereUI assumed those
options; six pages remain. Legacy Quest XP setting names migrate without overwriting newer
saved values. These changes are offline-tested; the user confirmed “All fixed.” on 2026-08-27. See CURRENT_STATE.md for the exact build and limits of this report.

## 3. Broader inventory functionality

Historical request covered searching all characters, bags, banks, mail, auctions, warband/guild storage, gold/currencies. Current code scans bags, personal bank and currency list and aggregates cached locations; dedicated mail/auction/warband/guild scanners and a search UI are not present. Existing data tables/tooltip labels are not implementation. Keep as a future scope decision; do not advertise complete live tracking.

## 5. Release assurance / backup

Offline mocks do not verify real EUI render layers, combat taint, or every retail API behavior. Follow TESTING.md for releases. No upstream/remote repository or off-machine backup has been configured; local Git and the supplied snapshot only protect against local editing mistakes. Publishing/backing up to a remote requires a separate destination/authorization.

## 6. Historical coverage limits

The main chat was recovered as 204 turns spanning Aug 5–27 from cached paginated reads, including a terminal oldest page and refreshed newest page. Identified local development task texts were consolidated; mixed-topic Website/WoW material is selectively indexed. Binary attachments are not a complete archive, and unrelated chats were not exhaustively read for incidental mentions. No claim is made that inaccessible/deleted/other-account chats have been merged. Use source IDs in HISTORY.md to revisit any missing context.

## 7. Reset / Disable All redesign

The first v1.1.3 implementation was withdrawn after repeated disconnects in the
test build. Revisit only after the rollback build is stable. Avoid synchronizing
all source ownership and refreshing every feature inside one live options reset
callback; stage changes for the next login instead.
