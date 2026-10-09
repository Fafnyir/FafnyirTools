# Feature requirements and actual baseline

The source and explicit user decisions outrank old assistant descriptions. “Present” below means code exists in the adopted baseline; it does not imply exhaustive runtime validation.

| Feature | Baseline contract | Status |
| --- | --- | --- |
| Identity/integration | Fafnyir Tools for EllesmereUI; requires EllesmereUI and FafnyirMedia; description “A collection of enhancements for EllesmereUI.”; independent Fafnyir sidebar group; existing category/logo metadata and Patreon link | Present |
| Resting | Animated resting indicator on EUI Player frame; configurable enable, max-level visibility, size and offsets; drawn above frame border | Present |
| Right-click self cast | Applicable EUI action buttons cast on self on right-click; preserve normal left-click behavior and toggle; secure attributes follow paging without action-slot/binding event refreshes | Present |
| Flyout Fix | Retail only: preserve Blizzard's native pooled-button geometry and flyout background while fitting the parent action bar's EllesmereUI border style/color to each button; restore tracked presentation when inactive and preserve the saved toggle. Hidden and inactive on Forever, where EllesmereUI handles flyouts natively | Present; replacement requires in-game confirmation |
| Icon History border | Default-off persistent toggle under QoL for EllesmereUI Damage Meter Icon History, with a live dropdown of all EllesmereUI border styles; Pixels is initially selected | Present; offline-tested, in-game confirmation pending |
| Focus reaction header | Independent Blizz Colored Focus Header toggle using EllesmereUI's supported Focus setting and reload path; full Focus Frame only, not Focus Target | Present; offline-tested, in-game confirmation pending |
| Aura Skins | Blizzard Target aura styling only; Player buffs/debuffs remain controlled by EllesmereUI. Target availability follows effective Target source, not blanket EUI addon presence; hold ownership for the session until reload | Present |
| Target aura layout | Buffs and debuffs wrap after six icons; independent Target icon size, filters, border/zoom/text settings | Present; mocked sizes 16/32/60; historical user confirmation |
| Focus auras | Distinct from Focus source selection; no custom Focus aura implementation | Not implemented |
| SharedMedia target arrows | Unit Frames selector uses arrow-named SharedMedia backgrounds and paired `targetarrow` artwork, includes FafnyirMedia Glow, retains native positioning/visibility/scale/color, restores native textures when disabled or unavailable | Present; offline-tested, in-game confirmation pending |
| FafnyirMedia role icons | Default-off Party/Raid-only artwork replacement; preserve native role filters, visibility, sizing and positioning; exclude main and extra frames | Present; offline-tested; Party and Raid confirmed by user 2026-10-03 |
| Status textures | Hide relevant Blizzard Target/Focus status textures without adding a toggle | Present |
| Device Layout | Per-installation Edit Mode default, spec overrides, safe switching and concise loaded-layout chat message | Present; not hardware identification or cross-machine sync |
| Inventory | Character bag/bank/currency caches, gold totals, item-location tooltips with class-colored names; targeted cached-alt removal and confirmed Reset All Characters; omit redundant Fafnyir Tools tooltip heading | Present foundation |
| Wider inventory locations | Warband/guild/mail/auction data structures and aggregation exist, but dedicated scanners/search UI are not implemented in this baseline | Incomplete; do not advertise full tracking |
| Persistent Companion Pet | Per-character specific/random favorite companion (not combat-pet frame persistence), shared enable/safety controls; QoL category; retain credit | Restored in consolidated v1.1.2; offline tests pass |
| About | Version, history, credits, support link and privacy-safe copyable diagnostics | Reports client/dependency versions, compatibility and feature state without character/account/raw SavedVariables data; offline-tested, in-game confirmation pending |

Current options pages: About, QoL, Unit Frames (including Aura Skins and Resting), Action Bars, Bags & Inventory, Layouts.

Retired in v1.1.5: Blizzard Bar Art and Unit Frame Sources are now provided by
EllesmereUI. Their FafnyirTools modules, options, defaults, export/import schema,
reset behavior and runtime writes are removed. Existing legacy SavedVariables
remain untouched during ordinary upgrades.

Retired in v1.1.11: First Name / Last Name / Whole Name formatting is now
provided by EllesmereUI on all frames. FafnyirTools no longer wraps
`WithSurname`, exposes the Forever-only dropdown, resets or transfers the
setting. Existing legacy `unitFrameNames` data remains untouched during
ordinary upgrades.

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

## XP ownership — retired 2026-10-06

EllesmereUI now owns the entire XP bar, including quest overlays. FafnyirTools
must not load an XP module, expose XP options/page, subscribe to XP/quest-only
events, alter gradients/layers/text/borders, or export/import/reset XP settings.
Preserve legacy xpBar SavedVariables as unknown data without migration or writes.
PLAYER_LEVEL_UP remains subscribed for the independent Resting feature.

## Preservation boundaries

Changing source ownership, category labels, XP defaults, filter choices or module inventory is a product change requiring appropriate scope and tests. Do not infer approval from a historical proposal. The active source is the working baseline, while previously accepted omissions remain visible in OPEN_ITEMS.md for restoration decisions.

Legacy XP settings remain untouched. Companion settings and per-character choices are preserved.
