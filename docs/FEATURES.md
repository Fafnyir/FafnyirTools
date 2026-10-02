# Feature requirements and actual baseline

The source and explicit user decisions outrank old assistant descriptions. “Present” below means code exists in the adopted baseline; it does not imply exhaustive runtime validation.

| Feature | Baseline contract | Status |
| --- | --- | --- |
| Identity/integration | Fafnyir Tools for EllesmereUI; requires EllesmereUI and FafnyirMedia; description “A collection of enhancements for EllesmereUI.”; independent Fafnyir sidebar group; existing category/logo metadata and Patreon link | Present |
| Resting | Animated resting indicator on EUI Player frame; configurable enable, max-level visibility, size and offsets; drawn above frame border | Present |
| Right-click self cast | Applicable EUI action buttons cast on self on right-click; preserve normal left-click behavior and toggle; secure attributes follow paging without action-slot/binding event refreshes | Present |
| Flyout Fix | Retail only: preserve Blizzard's native pooled-button geometry and flyout background while fitting the parent action bar's EllesmereUI border style/color to each button; restore tracked presentation when inactive and preserve the saved toggle. Hidden and inactive on Forever, where EllesmereUI handles flyouts natively | Present; replacement requires in-game confirmation |
| Icon History border | Default-off persistent toggle under QoL for EllesmereUI Damage Meter Icon History, with a live dropdown of all EllesmereUI border styles; Pixels is initially selected | Present; offline-tested, in-game confirmation pending |
| Forever unit-frame names | First Name / Last Name / Whole Name display for surname-bearing players on EllesmereUI main unit frames; Party, Raid, Nameplates, configured nicknames, NPCs, and Retail remain unchanged | Present; offline-tested, in-game confirmation pending |
| Focus reaction header | Independent Blizz Colored Focus Header toggle using EllesmereUI's supported Focus setting and reload path; full Focus Frame only, not Focus Target | Present; offline-tested, in-game confirmation pending |
| Aura Skins | Blizzard Target aura styling only; Player buffs/debuffs remain controlled by EllesmereUI. Target availability follows effective Target source, not blanket EUI addon presence; hold ownership for the session until reload | Present |
| Target aura layout | Buffs and debuffs wrap after six icons; independent Target icon size, filters, border/zoom/text settings | Present; mocked sizes 16/32/60; historical user confirmation |
| Focus auras | Distinct from Focus source selection; no custom Focus aura implementation | Not implemented |
| Status textures | Hide relevant Blizzard Target/Focus status textures without adding a toggle | Present |
| Device Layout | Per-installation Edit Mode default, spec overrides, safe switching and concise loaded-layout chat message | Present; not hardware identification or cross-machine sync |
| Inventory | Character bag/bank/currency caches, gold totals, item-location tooltips with class-colored names; targeted cached-alt removal and confirmed Reset All Characters; omit redundant Fafnyir Tools tooltip heading | Present foundation |
| Wider inventory locations | Warband/guild/mail/auction data structures and aggregation exist, but dedicated scanners/search UI are not implemented in this baseline | Incomplete; do not advertise full tracking |
| Persistent Companion Pet | Per-character specific/random favorite companion (not combat-pet frame persistence), shared enable/safety controls; QoL category; retain credit | Restored in consolidated v1.1.2; offline tests pass |
| About | Version, history, credits, support link | History and original companion credits restored; measured text wrapping |

Current options pages: About, QoL, Unit Frames (including Aura Skins and Resting), Action Bars, XP & Progression, Bags & Inventory, Layouts.

Retired in v1.1.5: Blizzard Bar Art and Unit Frame Sources are now provided by
EllesmereUI. Their FafnyirTools modules, options, defaults, export/import schema,
reset behavior and runtime writes are removed. Existing legacy SavedVariables
remain untouched during ordinary upgrades.

## WoW Forever beta contract

- Support interface 16001 alongside the existing Retail interface list.
- Detect Forever from the 16000–19999 interface range; its current
  `WOW_PROJECT_ID` classification is not a sufficient product test.
- Resolve the Resting indicator's max level from client APIs.
- Support current owned-pet IDs plus the legacy indexed Pet Journal path.
- While EllesmereUI reports the beta SavedVariables defect, block operations
  that write cross-addon settings and immediately reload. Retail is unaffected.
- Retain the legacy Forever fog saved-data shape for upgrade compatibility, but
  do not expose or apply it. Blizzard now restores `volumeFog` immediately, so
  presenting a persistent toggle would be misleading.

## Global settings transfer

- v1.1.3 exports a versioned, typed string containing recognized global preferences.
- Imports parse data without `loadstring`, reject malformed/oversized payloads, merge recognized fields, preserve unknown fields, and create a rollback snapshot before applying.
- Per-character companion selections, inventory/economy caches, and device-specific Edit Mode layouts are excluded.
- Import requires explicit confirmation and a UI reload.

## XP contract

- XP text layout is owned by EllesmereUI. FafnyirTools must not create,
  reposition, or hook duplicate XP text regions. The legacy three-zone toggle
  may remain in SavedVariables for downgrade safety but is not active or exported.

- Current gradient defaults: `#5563FF` to `#C561FF`, alpha 1 at both ends.
- Rested defaults: `#4F8FFF` at both ends, alpha 1.
- Quest default: `#FF9600`, alpha 1, enabled by default.
- Existing current-gradient enable default remains **false**; the repair changes colors, not that preference. Rested gradient default remains true and follows the existing gradient module behavior. Quest enable is independent.
- Sum positive XP rewards for completed, non-header, non-hidden quests in the current quest log; avoid duplicates and incomplete quests.
- Begin the orange segment at current XP and extend by the summed reward; clip at the current level boundary.
- Render current XP above Rested XP and Rested XP above Quest XP. The Quest XP
  segment must not cover an overlapping Rested XP segment.
- Refresh at login/world entry and registered quest/XP/level/exhaustion/data-load events; respond to bar value, size and show updates.
- Hide the segment at effective max level, when XP is disabled/invalid, no completed reward exists, or its own toggle is off. Inherit bar visibility; do not force the EUI holder visible.
- Keep the user's selected quest unchanged and use explicit quest-ID reward lookup. Failed selection-setter approaches from v1.1.0 experiments are not current design.
- Preserve custom saved colors/alpha and saved enable choices; fill missing values only. An explicit Reset action is allowed to restore defaults.
- XP Bar border styling is owned by EllesmereUI. FafnyirTools must not expose or
  apply a duplicate border control. Legacy FafnyirTools border keys may remain
  in SavedVariables for downgrade safety but are not active defaults or exports.

## Preservation boundaries

Changing source ownership, category labels, XP defaults, filter choices or module inventory is a product change requiring appropriate scope and tests. Do not infer approval from a historical proposal. The active source is the working baseline, while previously accepted omissions remain visible in OPEN_ITEMS.md for restoration decisions.

Legacy questXPEnabled/questXPColor keys migrate only when questEnabled/questColor are absent; existing new values win. Companion settings and per-character choices are preserved.
