# Open items — no silent restoration

## Resolved in consolidated v1.1.2

Persistent Companion Pet, QoL, companion defaults/events/TOC/options, prior
release history and companion credits are restored. The prior source credited
raine for the original WeakAura; that existing attribution is retained (not a
new independent author verification). Eiya credit is retained as well.

Options are consolidated to seven pages with Resting under Unit Frames,
XP & Progression and Layouts. This preserves later Aura/source and Action Bars
grouping. Legacy Quest XP setting names now migrate without overwriting newer
saved values. These changes are offline-tested; in-game validation is pending.

## 3. Broader inventory functionality

Historical request covered searching all characters, bags, banks, mail, auctions, warband/guild storage, gold/currencies. Current code scans bags, personal bank and currency list and aggregates cached locations; dedicated mail/auction/warband/guild scanners and a search UI are not present. Existing data tables/tooltip labels are not implementation. Keep as a future scope decision; do not advertise complete live tracking.

## 4. Focus aura styling

Focus source control exists. Custom Focus aura containers do not. Treat as a separate feature request if desired.

## 5. Release assurance / backup

Offline mocks do not verify real EUI render layers, combat taint, or every retail API behavior. Follow TESTING.md for releases. No upstream/remote repository or off-machine backup has been configured; local Git and the supplied snapshot only protect against local editing mistakes. Publishing/backing up to a remote requires a separate destination/authorization.

## 6. Historical coverage limits

The main chat was recovered as 204 turns spanning Aug 5–27 from cached paginated reads, including a terminal oldest page and refreshed newest page. Identified local development task texts were consolidated; mixed-topic Website/WoW material is selectively indexed. Binary attachments are not a complete archive, and unrelated chats were not exhaustively read for incidental mentions. No claim is made that inaccessible/deleted/other-account chats have been merged. Use source IDs in HISTORY.md to revisit any missing context.
