# Current state — v1.1.2 feature restoration, 2026-08-27

## 2026-09-01 pending in-game verification

Pet Frame is now included as the sixth selective Unit Frame source. It uses the native EllesmereUI `pet` source key, preserves existing SavedVariables through an inherited default, and retains the three established choices and reload behavior. Offline verification and a distinct package are required before treating this as user-confirmed.

The user requested “get me a full featured and fixed 1.1.2” in task
01a04568-9348-7180-8adf-921ebcbdd3b7. Scope: restore all previously delivered
features and fix integration omissions, without adding discarded experiments
or unfinished wishlist features.

## Active source

src/FafnyirTools contains 20 files, including restored PermanentCompanionPet.lua.
The prior QuestXPFixed baseline remains immutable in releases/ and its baseline
tag/fingerprint. Active source now intentionally differs from that baseline.

Restored per-character companion selections, legacy migration, safety checks,
QoL controls, event registrations, v1.0.8-v1.1.1 history and original credits.
Older questXPEnabled/questXPColor preferences migrate only when new keys are
missing. Existing new keys/custom settings take precedence.

Seven pages: About / QoL / Unit Frames / Action Bars / XP & Progression /
Bags & Inventory / Layouts. Unit Frames contains source controls, Aura Skins,
then Resting. /faftools opens Unit Frames. About uses measured wrapped text height.

## Preservation

UnitFrameSources, AuraSkins, action modules, inventory modules, status-texture
hiding and sidebar are unchanged. XP, Resting and DeviceLayout behavior is
unchanged; only their page labels moved. Version remains v1.1.2.

## Validation

Combined offline checks pass: all 18 Lua files, TOC/module contracts, seven real
feature pages, existing XP/aura/source/action-options suites, and new companion
migration/modes/character isolation/safety/throttle/events tests. Legacy XP
migration, slash navigation and About wrapping are covered.

User reported “All fixed.” on 2026-08-27 in task 01a04568-9348-7180-8adf-921ebcbdd3b7 after receiving FullFixed. This records user confirmation, not an exhaustive test matrix; client/EUI versions were not supplied.

Confirmed source commit: 0adfac04691d151a03cfcbf3dfed48b2e533f10f.
FullFixed archive SHA256: dccdf5bb22d8bec1cbcdef107efd0001bdb6f3b8edaab5ee8b41556fafd61e4a.
The exact archive is retained in releases/; see docs/baselines/v1.1.2-full-fixed.json.
Future changes start from this source, preserving SavedVariables.
No installed WoW files or upstream files were modified; no public release made.

Broader inventory scanners/search, Focus aura styling and discarded experiments
remain outside this restoration. See OPEN_ITEMS.md.
