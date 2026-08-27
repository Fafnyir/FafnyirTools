# Current state — 2026-08-27

## Active source and provenance

`src/FafnyirTools` is byte-identical to `releases/Fafnyir_Tools_for_EllesmereUI_v1.1.2_QuestXPFixed.zip`.

ZIP SHA-256: `0f8d3bff41f5d505cc499721ccc21381d38b9ebbf19dbb9e87cc89a4435d0caf`.

User confirmation: “Fixed.” in **Fix missing Quest XP overlay**, task `01a04568-9348-7180-8adf-921ebcbdd3b7`, on 2026-08-27. That confirms the reported fix, not every possible client, combat state, setting or feature.

The Quest XP repair changed only Core/Bootstrap.lua, Core/Events.lua and Modules/XPBar.lua relative to the exact uploaded v1.1.2. Every other addon file was preserved. This consolidation leaves all 19 addon files unchanged again.

## Current options pages

About; Resting; Action Bars; Unit Frames; Device Layout; XP Bar; Bags & Inventory.

Action Bars contains Right-Click Self Cast, Blizzard Bar Art, Flyout Fix. Unit Frames contains five source controls followed by Aura Skins. XP Bar contains current/rested gradient settings plus completed Quest XP toggle/color.

## Known discrepancy

Persistent Companion Pet was implemented and user-tested in v1.0.9, retained under QoL in v1.1.1, but omitted from this v1.1.2 lineage. The older QoL page and some category renames are also absent. The v1.1.2 About changelog skips v1.0.8–v1.1.1 and does not mention the new Quest XP repair. These are documented open items, not silently merged during consolidation.

## Validation status

Offline checks: Lua 5.1 syntax; unique/resolving TOC entries; all expected modules; XP totals/colors/events/geometry/visibility/settings; 15 unit source choices; legacy inherited settings; reload callbacks; AuraKit availability/ownership; six-icon row widths; combined options layout; packaging integrity.

Historical user reports: bar art and flyout fixes worked in the Aug 23 task; per-character companion pet worked in v1.0.9; XP overlay worked in v1.1.0; v1.1.1 options tested; Target auras/six-icon rows and EUI bosses tested in the Aug 27 source task; current Quest XP repair reported fixed here.

No new in-game session is run during consolidation. See TESTING.md for remaining manual coverage and OPEN_ITEMS.md for absent/incomplete features.
