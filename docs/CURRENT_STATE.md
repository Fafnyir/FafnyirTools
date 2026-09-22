# Current state — v1.1.4 Forever beta, 2026-09-22

## Blizzard Bar Art persistence repair

The v1.1.3 artwork could disappear after runtime action-bar transitions because
it refreshed only at login and on size changes and retained its original
`MainActionBar.BorderArt` and `EndCaps` references. The v1.1.4 line now
reacquires live artwork and restores it after paging, specialization, vehicle,
override, shapeshift, Edit Mode, world-entry, and combat transitions. Hooks also
repair direct hide, alpha, or parent changes. Offline regression coverage passes;
in-game confirmation is still required.

## 2026-09-20 WoW Forever beta package

The `forever-beta` branch targets Forever 1.60.1.69913 (interface 16001) and
EllesmereUI 9.2.1 while preserving the accepted Retail v1.1.3 behavior.
Inspection of the installed Forever EllesmereUI source confirms that it retains
the Unit Frame source API, AuraKit, EAB action buttons, Edit Mode and XP frame
names used by FafnyirTools.

The compatibility build declares interface 16001, detects Forever from its
interface range, resolves maximum level through client APIs instead of the
former hard-coded Retail level 90, and supports the current Pet Journal owned-ID
enumeration while retaining the indexed fallback.

Forever 1.60.1 has an upstream SavedVariables persistence defect documented by
EllesmereUI as `EllesmereUI.FOREVER_SV_BUG`. While that flag is active,
FafnyirTools blocks Unit Frame source writes, settings import/backup restore and
Full Reset because those operations depend on safe persistence across reloads.
Export remains available. This package is offline-validated but intentionally
not presented as in-game verified until the client defect is fixed.

The v1.1.4 beta line also adds a Forever-only **Volumetric Fog** toggle under
QoL. It controls the live `volumeFog` CVar and does not store a duplicate addon
preference. Blizzard persists that client setting through `Config.wtf`, outside
the affected addon SavedVariables path. Retail does not display the section.

The user approved the stable Safe EllesmereUI Reset Defaults build as the
v1.1.3 release on 2026-09-09. This records acceptance of the tested build, not
an exhaustive client/API regression matrix. The withdrawn Reset/Disable All
experiment remains excluded.

## 2026-09-09 global settings transfer

The user authorized starting v1.1.3 with global settings export/import. The top
of the About page now exports a versioned, typed FafnyirTools string and validates it
without executing imported text. Import merges only recognized settings,
creates a rollback snapshot first, requires confirmation and reloads the UI.

Exports intentionally exclude per-character companion choices, all inventory
and economy caches, and device-specific Edit Mode layout selections. Existing
unknown settings survive import. Offline verification passes. The user
successfully exported, reset, and imported without a Lua error; the subsequent
one-reload source synchronization repair is included in the accepted release.

The first in-game import stored the correct Unit Frame source values but needed
a second reload to change the frames. Import had updated FafnyirToolsDB only;
EllesmereUI's separate source profile was not synchronized until PLAYER_LOGIN,
after frame construction. Import and backup restore now call the existing native
source apply path before ReloadUI so one reload can construct the selected frames.

The 2026-09-09 Reset/Disable All trial (`2d3733c`) was withdrawn after the
user experienced repeated disconnects while running that build. The change was
reverted in full. No Lua error or new client crash report was found, so causality
is not proven; stability must be re-established before redesigning the feature.

After the rollback build remained stable in user testing, EllesmereUI was
restored as the explicit reset value for all six Unit Frame sources. The safer
implementation completes the existing feature reset loop first, then applies
only the six source values through the native EUI API and offers one reload. It
does not restore the withdrawn Disable All action or add source writes inside
the unordered feature-refresh loop.

## 2026-09-08 XP bar border Trial 1

The XP & Progression page now exposes EllesmereUI-native border style, size,
color and opacity controls for one shared outer XP bar border. Border size zero
disables it. The change preserves existing XP/Quest/Rested settings and fills
only missing border defaults. Offline verification passes; in-game visual
confirmation remains required.

The first in-game screenshot showed the configurable border stacked on the
inset StatusBar alongside EllesmereUI's native outer edge. The implementation
now restyles EllesmereUI's existing outer border host directly, eliminating the
doubled and one-pixel-inset appearance; this correction passes offline checks.
The Blizzard textured style then exposed a second layering issue: its backdrop
used the native host level and rendered behind the StatusBar fill. The host is
now raised one frame level above the fill while remaining below EUI's text host.
The next screenshot showed the Blizzard texture still fitted too tightly. XP
was incorrectly passed as an unregistered `databars` defaults profile, which
forced zero offsets. XP borders now use EllesmereUI's built-in per-texture
defaults (Blizzard: 3px horizontal, 2px vertical).
The user reported the resulting aligned Blizzard border as “Perfect” on
2026-09-08, providing in-game visual confirmation for Trial 1.

## 2026-09-03 Target-only Aura Skins

At the user's direction, FafnyirTools no longer styles or exposes controls for the main Player buff/debuff frames; EllesmereUI controls those. Aura Skins now operates on Blizzard Target auras only. Existing saved keys are left intact for upgrade safety but are no longer exposed or applied to Player aura frames. Offline verification passes; in-game confirmation is pending.

## 2026-09-03 Aura control clarification

The user clarified that Target aura controls work. The apparent size failure came from using the main Player aura `Icon Size` control. Both Target repair attempts were reverted. Active source only clarifies labels: Player Aura Size and Player Aura Expand Button are Player-frame controls; icon zoom and aura text size remain shared by Player and Target. In-game confirmation of the wording is pending.

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
