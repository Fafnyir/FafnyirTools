# Feature requirements and actual baseline

## v2.0.0 standalone test availability

| Feature | Standalone | With EllesmereUI |
| --- | --- | --- |
| About, diagnostics and global settings | Native Fafnyir Tools window | EllesmereUI sidebar |
| Leveling Forecast and Refresh | Yes | Yes |
| Device Layout | Yes | Yes |
| Right-click self cast | Blizzard action bars | EllesmereUI and supported action bars |
| Persistent Companion Pet | Retail | Retail |
| Inventory tracking | Forever | Forever |
| Resting, Aura Skins, Focus Header | Hidden; requires EllesmereUI frames | Yes |
| Icon History, BigWigs borders, click reticle | Hidden; requires EllesmereUI APIs | Yes |
| Shared target/role artwork | Hidden; requires EllesmereUI and media | Yes |

Standalone mode must never delete or rewrite dormant integration settings.
Installing EllesmereUI later restores the complete integration feature set.
The user confirmed the EllesmereUI-installed v2 test is functional with no
errors on 2026-10-31; standalone and exhaustive cross-client coverage remain
separate.

## Localization

- English is the fallback locale. Simplified Chinese (`zhCN`) and Traditional
  Chinese (`zhTW`) provide complete coverage of all 193 current interface
  strings. Yilang reviewed the strings through v1.1.19; the v1.1.20 Refresh and
  v2.0.0 standalone strings are first-pass translations pending fluent review.
- Locale files load before feature modules so localized page names are stable
  when EllesmereUI registers the options pages.
- Saved values, feature registry keys, export field names and other runtime
  identifiers stay language-neutral; only user-facing text is translated.
- Missing locale keys fall back to English and then to the key itself. Format
  failures return the untranslated string rather than raising a Lua error.
- About changelog history, credits, support diagnostics and dynamic sentences
  not supplied by the volunteer may remain English until a reviewed follow-up.
- Yilang reviewed the 11 v1.1.17 BigWigs-border and click-only Center Reticle
  strings; the returned wording is integrated in both Chinese locales.

The source and explicit user decisions outrank old assistant descriptions. “Present” below means code exists in the adopted baseline; it does not imply exhaustive runtime validation.

| Feature | Baseline contract | Status |
| --- | --- | --- |
| Identity/integration | Fafnyir Tools; EllesmereUI and FafnyirMedia are optional; standalone description and native window without EUI, independent Fafnyir sidebar group with EUI, existing category and Patreon link | v2.0.0 test |
| Resting | Animated resting indicator on EUI Player frame; configurable enable, max-level visibility, left/right placement, size and offsets; drawn above frame border | Present |
| Right-click self cast | Applicable EUI action buttons cast on self on right-click; preserve normal left-click behavior and toggle; secure attributes follow paging without action-slot/binding event refreshes | Present |
| Flyout Fix | Retired on both clients; EllesmereUI owns spell-flyout presentation. Legacy SavedVariables remain untouched | Removed after EllesmereUI 9.7 audit |
| Icon History border | Default-off persistent toggle under QoL for EllesmereUI Damage Meter Icon History, with a live dropdown of all EllesmereUI border styles; Pixels is initially selected | Present; offline-tested, in-game confirmation pending |
| BigWigs border | Default-off choice of all current EllesmereUI borders on BigWigs timer bars, attached spell icons and normal message icons; Pixels default; message borders follow icon fades; shared 0–10 spacing moves bar bodies from fixed icons/indicators and separates message icons from text; leaves profiles and nameplate icons untouched | v1.1.17 test; initial bar border confirmed in game, revised scope pending |
| Click-only Center Reticle | Default-off QoL toggle that shows EllesmereUI's enabled Center Reticle only while the left or right mouse button is held; preserves EllesmereUI's own reticle preference, color, opacity and size | v1.1.17 test; offline-tested, in-game confirmation pending |
| Focus reaction header | Independent Blizz Colored Focus Header toggle using EllesmereUI's supported Focus setting and reload path; full Focus Frame only, not Focus Target | Present; offline-tested, in-game confirmation pending |
| Aura Skins | Blizzard Target aura styling only; Player buffs/debuffs remain controlled by EllesmereUI. Target availability follows effective Target source, not blanket EUI addon presence; hold ownership for the session until reload | Present |
| Target aura layout | Buffs and debuffs wrap after six icons; independent Target icon size, filters, border/zoom/text settings | Present; mocked sizes 16/32/60; historical user confirmation |
| Focus auras | Distinct from Focus source selection; no custom Focus aura implementation | Not implemented |
| SharedMedia target arrows | Unit Frames selector uses arrow-named SharedMedia backgrounds and paired `targetarrow` artwork, includes FafnyirMedia Glow, retains native positioning/visibility/scale/color, restores native textures when disabled or unavailable | Present; offline-tested, in-game confirmation pending |
| FafnyirMedia role icons | Default-off Party/Raid-only artwork replacement; preserve native role filters, visibility, sizing and positioning; exclude main and extra frames | Present; offline-tested; Party and Raid confirmed by user 2026-10-03 |
| Status textures | Hide relevant Blizzard Target/Focus status textures without adding a toggle | Present |
| Device Layout | Per-installation Edit Mode default, spec overrides, safe switching and concise loaded-layout chat message | Present; not hardware identification or cross-machine sync |
| Inventory | Forever only: character bag/bank/currency caches, gold totals, item-location tooltips with class-colored names, targeted cached-alt removal and Reset All Characters. Retail delegates offline inventory and tooltip counts to EllesmereUI Bags | Present on Forever; retired on Retail |
| Wider inventory locations | Warband/guild/mail/auction data structures and aggregation exist, but dedicated scanners/search UI are not implemented in this baseline | Incomplete; do not advertise full tracking |
| Persistent Companion Pet | Retail only: per-character specific/random favorite companion with safety controls. Forever delegates the equivalent behavior to EllesmereUI Forever Essentials; retain historical credit and legacy data | Present on Retail; retired on Forever |
| Leveling Forecast | Read-only QoL summary of completed quest XP, effective adjusted/base quest bonus and projected post-turn-in progress; follows the guarded Midnight 80–90 XP curve and falls back to next-level overflow if the live current-level requirement changes; an in-place Refresh button rebuilds the page to recalculate without events or polling; never touches EllesmereUI's XP bar | v1.1.20 build `2184a77`; offline checks and user in-game test passed |
| About | Version, history, credits, support link and privacy-safe copyable diagnostics | Reports client/dependency versions, compatibility and feature state without character/account/raw SavedVariables data; offline-tested, in-game confirmation pending |

Current options pages: About, QoL, Unit Frames (including Aura Skins and
Resting), Action Bars, and Layouts. Bags & Inventory is additionally present on
Forever; Retail uses EllesmereUI Bags for the equivalent feature.

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

## XP bar ownership — retired 2026-10-06

EllesmereUI now owns the entire XP bar, including quest overlays. FafnyirTools
must not load an XP module, expose XP options/page, subscribe to XP/quest-only
events, alter gradients/layers/text/borders, or export/import/reset XP settings.
Preserve legacy xpBar SavedVariables as unknown data without migration or writes.
PLAYER_LEVEL_UP remains subscribed for the independent Resting feature.

The Leveling Forecast is an explicit exception for read-only reporting:
it may query current player XP and completed quest reward values when its QoL
options section is built. It must not restore the XP module/page, subscribe to
XP/quest events, alter EllesmereUI regions, or add XP settings and transfers.

## Preservation boundaries

Changing source ownership, category labels, XP defaults, filter choices or module inventory is a product change requiring appropriate scope and tests. Do not infer approval from a historical proposal. The active source is the working baseline, while previously accepted omissions remain visible in OPEN_ITEMS.md for restoration decisions.

Legacy XP settings remain untouched. Companion settings and per-character choices are preserved.
