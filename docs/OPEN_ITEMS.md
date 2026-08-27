# Open items — no silent restoration

## 1. Persistent Companion Pet omitted from v1.1.2

**Evidence:** implemented/tested in v1.0.9, present in the v1.1.1 ZIP, absent from adopted v1.1.2 source/TOC/defaults/events/options. The Aug 27 options-layout task explicitly left prior companion changes unmerged. This is a real omission relative to earlier accepted work, not a newly requested feature.

**Recovered source:** archive/recovered/v1.1.1 includes PermanentCompanionPet.lua plus Bootstrap, Events, Options, About and TOC context. The entire v1.1.1 ZIP is archived as well.

**Next focused task:** restore the feature into current src, merging only its dependencies, adding QoL controls, preserving per-character choices and legacy migration, adding mocked safety/migration tests, and testing in-game. Do not replace Bootstrap/Events/Options wholesale with old versions: that would lose Unit Frames and the current Quest XP fix again.

Preserve companion safety checks (combat/death/mount/stealth/taxi/vehicle/pet battle/PvP setting), throttle, mode and selected pet per character. Credit Eiya for the idea. The original WeakAura designer remains unverified; do not invent their name. Historical reference: https://wago.io/3It1XU72A (not re-fetched during this consolidation).

## 2. Options taxonomy and changelog reconciliation

Current pages differ from the v1.1.1 seven-category plan, and QoL is missing with Companion Pet. The v1.1.2 About history omits v1.0.8–v1.1.1 and the Quest XP repair; the Companion Pet credit is also absent. Decide the final taxonomy in a focused task, preserving later user-approved Unit Frames/Aura and Action Bars grouping. This repository's changelog preserves the recovered history without modifying the running addon.

## 3. Broader inventory functionality

Historical request covered searching all characters, bags, banks, mail, auctions, warband/guild storage, gold/currencies. Current code scans bags, personal bank and currency list and aggregates cached locations; dedicated mail/auction/warband/guild scanners and a search UI are not present. Existing data tables/tooltip labels are not implementation. Keep as a future scope decision; do not advertise complete live tracking.

## 4. Focus aura styling

Focus source control exists. Custom Focus aura containers do not. Treat as a separate feature request if desired.

## 5. Release assurance / backup

Offline mocks do not verify real EUI render layers, combat taint, or every retail API behavior. Follow TESTING.md for releases. No upstream/remote repository or off-machine backup has been configured; local Git and the supplied snapshot only protect against local editing mistakes. Publishing/backing up to a remote requires a separate destination/authorization.

## 6. Historical coverage limits

The main chat was recovered as 204 turns spanning Aug 5–27 from cached paginated reads, including a terminal oldest page and refreshed newest page. Identified local development task texts were consolidated; mixed-topic Website/WoW material is selectively indexed. Binary attachments are not a complete archive, and unrelated chats were not exhaustively read for incidental mentions. No claim is made that inaccessible/deleted/other-account chats have been merged. Use source IDs in HISTORY.md to revisit any missing context.
