# Reconciled project changelog

## v1.1.5 — cleanup

- Added the supplied Fafnyir mark beside the Fafnyir Tools module title.
- Added FafnyirMedia as a required dependency alongside EllesmereUI.
- Removed the XP Bar border controls after EllesmereUI added native support.
  Existing legacy FafnyirTools border keys are left untouched but are no longer
  applied, reset, displayed, or included in new global exports.
- Removed the three-zone XP Bar text override after EllesmereUI added the same
  layout natively. The legacy saved toggle is left untouched for downgrade
  safety but is no longer applied, reset, displayed, or exported.
- Corrected XP overlay layering so current XP renders on top, Rested XP renders
  second, and completed Quest XP remains behind both instead of covering Rested XP.
- Limited Flyout Fix to Retail. WoW Forever now uses EllesmereUI's native
  flyout handling, so FafnyirTools does not show the option, install hooks, or
  alter flyout buttons there; the saved Retail preference is preserved.
- Hidden the Forever-only Volumetric Fog option because Blizzard now restores
  the client setting immediately after addons change it.
- Stopped applying or repeatedly reapplying the unsupported `volumeFog` console
  setting while retaining its saved-data shape for upgrade compatibility.
- No new headline feature was added; this release is intentionally limited to
  compatibility cleanup and regression fixes.

## v1.1.4 — WoW Forever beta compatibility

User confirmed build `1aae4fe` working in game on 2026-09-26.

- Added an optional three-zone XP text layout with Level at left, current/max
  plus percentage at center, and rested XP percentage at right.
- Added the missing Blizzard-style Focus reaction-header toggle using
  EllesmereUI's existing Focus setting and refresh path.
- Added a Forever-only First Name / Last Name / Whole Name display option for
  surname-bearing characters on EllesmereUI main, Party, and Raid frames while
  leaving Nameplates unchanged.
- Added confirmed per-character removal and Reset All Characters controls for
  inventory tracking while preserving warband and guild caches.
- Linked the central Blizzard action-bar background and both side griffons to
  the existing Blizzard Bar Art toggle without exposing Blizzard's hidden
  end-cap editing panel.
- Fixed reload confirmations on Forever by using EllesmereUI's secure
  `reload = true` popup contract instead of calling protected `ReloadUI()`
  from an ordinary addon callback.
- Made Blizzard Bar Art reacquire and restore its native artwork after paging,
  specialization, vehicle, zone, combat, and Edit Mode transitions.
- Added a per-installation Art Scale control because the required visual
  calibration can vary between machines; global exports omit this value.
- Added Forever interface 16001 support and runtime detection.
- Replaced the Resting level-90 constant with client max-level APIs.
- Added current Pet Journal owned-ID enumeration with its legacy fallback.
- Guarded reload-dependent source/import/reset operations while EllesmereUI
  reports the Forever beta SavedVariables persistence defect.
- Added offline compatibility coverage and a pending in-game test matrix.
- Added a Forever-only Volumetric Fog toggle backed by the persistent client
  `volumeFog` console setting.
- Store the fog preference in FafnyirTools and reapply it after login and world
  changes because Forever can overwrite the graphics state.

## 2026-09-09 — v1.1.3 global settings transfer

User accepted the stable Safe EllesmereUI Reset Defaults build as v1.1.3.

- Added versioned, validated export/import for recognized global preferences.
- Excluded character selections, inventory/economy caches, and device layouts.
- Added confirmation, pre-import rollback data, and reload-on-import behavior.
- Moved Global Settings to the top of the About page.
- Synchronize imported Unit Frame sources into EllesmereUI before reload, avoiding a second reload.
- Withdrew and fully reverted the Reset/Disable All trial after repeated disconnects in user testing.
- Restored EllesmereUI as all six Unit Frame reset defaults using a staged, source-only synchronization after normal reset refreshes complete.

## 2026-09-08 — v1.1.2 XP bar border Trial 1

- Added EllesmereUI-native style, size, color and opacity controls for one shared XP bar border.
- Reused the XP bar's native outer border host to avoid a doubled, inset outline.
- Raised the shared border host above the XP fill so textured styles remain visible.
- Use EllesmereUI's built-in texture offsets instead of an unregistered data-bar profile.
- User-confirmed the final XP border alignment in game on 2026-09-08.

This file reconstructs the development history from the identified chats and source packages. It does not assert external publication. Original package notes remain untouched.

## 2026-09-03 — v1.1.2 Target-only Aura Skins options

- Removed Player/main buff and debuff controls from FafnyirTools; EllesmereUI remains their sole owner.
- Kept and explicitly labeled Target size, zoom, duration text/format, text size, filters and border controls.

## 2026-09-03 — v1.1.2 Aura option clarification

- Reverted the Target size/zoom repair attempts after the user confirmed Target controls already work.
- Renamed the main Player aura size/expand controls and marked shared Player/Target zoom and text controls to prevent confusion.

## 2026-09-01 — v1.1.2 Pet Frame source control

- Added Pet Frame to selective Unit Frame sources using EllesmereUI's native source API.
- Preserved existing SavedVariables with an inherited default and retained EllesmereUI / Blizzard Default / Hidden choices plus reload behavior.

## 2026-08-27 — Consolidated v1.1.2 feature restoration

- Restored Permanent Companion Pet and QoL with per-character settings and safety/event integration.
- Migrated older Quest XP preference names only when new keys are missing.
- Consolidated seven options pages; moved Resting under Unit Frames and updated slash navigation.
- Restored missing About history/credits; measured wrapped text height.
- Added companion/event/migration/real-page tests; all combined offline checks pass.
- Kept XP/aura/source/action behavior and version; user confirmed “All fixed.” on 2026-08-27 (see docs/CURRENT_STATE.md).

## 2026-08-27 — Repository consolidation (addon still v1.1.2)

- Adopted the user-confirmed QuestXPFixed ZIP as the authoritative, unchanged source.
- Added durable feature requirements, decisions, omission tracking, history snapshots and prior-build fingerprints.
- Consolidated XP, aura/source and options regressions into one verification command.
- Added clean-tree packaging with Git revision and SHA-256 manifest.
- Recorded missing Companion Pet/QoL and incomplete inventory scope instead of silently merging them.

## v1.1.2 — Selective Unit Frames and Quest XP repair

- Player, Target, ToT, Focus, Boss source controls; native API and reload prompt.
- Three source choices; legacy inherited choices display the effective source without migration writes.
- Blizzard Target aura skins coexist with other EUI frames; six icons per row.
- Action Bars groups self-cast, bar art and flyout fix; Aura Skins under Unit Frames.
- Repaired lost Quest XP, restored intended defaults and preserved saved settings.
- Persistent Companion Pet from v1.1.1 is not included in this lineage; tracked as an omission.

## v1.1.1 — Options organization

- Seven Fafnyir-owned categories; Companion Pet under QoL; retained v1.1.0 XP work.
- User reported “tests perfect.” Parts of this organization did not carry into v1.1.2.

## v1.1.0 — Quest XP

- Added completed-quest XP overlay, toggle/color, event updates and intended color defaults.
- Initial lookup/layering attempts failed; final build received user confirmation and temporary diagnostics were removed.

## v1.0.9 — Companion Pet

- Persistent companion summoning; specific/random favorite modes.
- Per-character mode/name selections; user reported it worked.
- Credit Eiya for the idea; original WeakAura designer attribution not established.

## v1.0.8 — Bar art and flyouts (Aug 23 lineage)

- Restored/scaled/aligned native artwork to EUI Bar 1 with toggle.
- Flyout buttons inherit parent border style; Flyout Fix toggle.
- Temporary UI Tweaks grouping later superseded.
- The different Aug 20 v1.0.8 Masque experiment was discarded; do not confuse the packages.

## v1.0.7

- AuraKit-based Blizzard Target aura handling, independent size and filtering.
- Automatic Target/Focus status texture hiding.

## v1.0.6

- Per-installation Edit Mode defaults, specialization overrides and short login message.

## v1.0.5

- Blizzard aura skinning and reload prompt; right-click self-cast compatibility.
- Removed redundant tooltip addon header. Early blanket EUI aura lockout later superseded.

## v1.0.4

- Class-colored inventory names; “Envisioned by Fafnyir” credit.

## v1.0.3

- About/version/history/support UI and inventory cache/tooltip foundation.

## v1.0.2

- XP gradient flickering and rested-white restoration fixes.

## v1.0.1

- XP/rested gradients, directions and color controls.

## v1.0.0

- Resting indicator, right-click self cast and independent EUI integration.
