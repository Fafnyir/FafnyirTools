# Reconciled project changelog

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
