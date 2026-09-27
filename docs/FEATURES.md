# Feature requirements and actual baseline

The source and explicit user decisions outrank old assistant descriptions. “Present” below means code exists in the adopted baseline; it does not imply exhaustive runtime validation.

| Feature | Baseline contract | Status |
| --- | --- | --- |
| Identity/integration | Fafnyir Tools for EllesmereUI; requires EllesmereUI and FafnyirMedia; description “A collection of enhancements for EllesmereUI.”; independent Fafnyir sidebar group; existing category/logo metadata and Patreon link | Present |
| Resting | Animated resting indicator on EUI Player frame; configurable enable, max-level visibility, size and offsets; drawn above frame border | Present |
| Right-click self cast | Applicable EUI action buttons cast on self on right-click; preserve normal left-click behavior and toggle | Present |
| Blizzard Bar Art | Detach/reparent recovered native artwork to Bar 1, link the central background and both side griffons to one toggle, follow movement/scaling, self-heal after runtime transitions, and preserve toggle; per-installation Art Scale calibration defaults to 1.06 and is excluded from global exports | Present; historical user confirmation plus offline persistence tests |
| Flyout Fix | Retail only: match parent action-button styling, including border style/color instead of forced white pixel borders; preserve the saved toggle. Hidden and inactive on Forever, where EllesmereUI handles flyouts natively | Present; historical Retail confirmation |
| Unit Frame Sources | Player, Target, Target of Target, Focus, Boss, Pet via native `SetUnitFrameSource`; values `eui`, `blizzard`, `hidden`; require reload | Present; offline tests cover all 18 combinations individually |
| Forever unit-frame names | Global First Name / Last Name / Whole Name display for surname-bearing players on EllesmereUI main, Party, and Raid frames; Nameplates, configured nicknames, NPCs, and Retail remain unchanged | Present; offline-tested, in-game confirmation pending |
| Focus reaction header | Independent Blizz Colored Focus Header toggle using EllesmereUI's supported Focus setting and reload path; full Focus Frame only, not Focus Target | Present; offline-tested, in-game confirmation pending |
| Unit Frame reset defaults | Full Reset sets all six sources to EllesmereUI after normal feature refresh completes, then offers one reload; upgrades preserve saved choices | Present in accepted v1.1.3 build |
| Legacy source settings | Keep `inherit` data untouched; display effective native source without writing a new override; unknown API must not invent a source | Present |
| ToT dependency | Blizzard ToT requires Blizzard Target; EUI may fall back to its ToT when Target is EUI | Existing tooltip/behavior contract |
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
