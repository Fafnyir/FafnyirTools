# Current state — v1.1.5 cleanup in development, 2026-09-26

## v1.1.5 cleanup scope

The user chose v1.1.5 as a maintenance release without a forced headline
feature. The Forever-only Volumetric Fog control is hidden because Blizzard now
restores `volumeFog` immediately after addons change it. FafnyirTools no longer
applies the setting at login or world transitions. Its existing saved table is
retained so upgrades do not discard user data or change the export schema.
FafnyirMedia is now declared as a required dependency alongside EllesmereUI.
XP Bar border styling is now owned by EllesmereUI. FafnyirTools no longer
displays or applies its former border controls. Existing legacy saved keys are
left untouched for downgrade safety, but are outside the active defaults and
global export schema.
The former three-zone XP text override is also retired because EllesmereUI now
provides the layout natively. FafnyirTools no longer creates text regions,
repositions EllesmereUI text, or hooks its text updates. The legacy saved toggle
is retained only for downgrade safety.
The completed Quest XP texture now uses EllesmereUI's XP artwork layer at
sublevel 1, below Rested XP at sublevel 2 and current XP at sublevel 4. This
prevents the orange Quest XP segment from covering the blue Rested XP segment.
Flyout Fix is now Retail-only. On Forever the module exposes no option, installs
no `SpellFlyout` hook, schedules no retry, and leaves the saved Retail choice
untouched.
On Retail the cleaner flyout implementation preserves Blizzard's pooled button
size, scale, anchors, icons and cooldown geometry. It fits only EllesmereUI's
selected decorative border to each native flyout button, preserves the native
flyout background, and restores tracked texture and border state when inactive.
It skips hidden pooled buttons so styling cannot revive stale spells left over
from a previously longer flyout menu.
Right-Click Self Cast no longer subscribes to `ACTIONBAR_SLOT_CHANGED` or
`UPDATE_BINDINGS`. Those events were unnecessary because the secure right-click
action follows each button's live `action` attribute, while the old handlers
could schedule repeated full 180-button refreshes during action/modifier churn.
Initialization, world entry, explicit option changes and post-combat deferral
remain the supported refresh paths.
Blizzard Bar Art and Unit Frame Sources are retired because EllesmereUI now
provides both capabilities. FafnyirTools no longer loads either module, displays
their options, exports/imports or resets their settings, or writes their runtime
state. Existing legacy saved keys remain untouched during ordinary upgrades.
Party and Raid frame handling is also removed from FafnyirTools First/Last/Whole
Name modes because EllesmereUI now provides those controls. The saved mode and
main-unit-frame behavior remain intact; Party, Raid and Nameplates use EllesmereUI.
Damage Meter Icon History now has a default-off FafnyirTools **Enable Icon
Border** option under QoL. Its Border Style dropdown reads EllesmereUI's live
border registry, including SharedMedia additions, and Pixels is the initial
selection. Both settings persist in FafnyirTools and the renderer preserves
hidden-slot visibility. Startup retries and a strip-show hook apply saved border
settings after EllesmereUI's delayed Icon History pool creation, avoiding the
former need to toggle the option off and back on after reload.

## v1.1.4 confirmed baseline

On 2026-09-26 the user reported that the latest v1.1.4 build worked perfectly
in game. Adopt package revision `1aae4fe` as the confirmed v1.1.4 baseline. This
confirmation includes the latest three-zone XP text with rested percentage,
Focus reaction-header toggle, main/Party/Raid name modes with Nameplates
excluded, unified Blizzard Bar Art, and inventory character-cache controls.

## Three-zone XP bar text (retired in v1.1.5)

The XP & Progression page now enables a three-zone text layout by default:
Level at left, current/max XP plus percentage at center, and rested XP percentage at right.
It inherited EllesmereUI's font styling and updated with XP/rested events.
EllesmereUI now supplies this layout itself, so v1.1.5 removes the duplicate
FafnyirTools option and implementation.

## Blizzard-style Focus reaction header

The Unit Frames page now exposes **Blizz Colored Focus Header**, matching
EllesmereUI's native Target control. It uses the renderer's supported Focus
setting, adopts an existing saved choice on first use, and refreshes immediately.
It changes only the full Focus Frame; Focus Target has no reputation strip.

## Forever unit-frame name display

The Unit Frames page now offers First Name, Last Name, and Whole Name for WoW
Forever characters rendered by EllesmereUI main unit frames. Whole Name preserves
the existing behavior and is the upgrade-safe default. Party, Raid, configured
nicknames, Nameplates, NPC names, secret names, and Retail are unchanged. The
shared EllesmereUI surname helper is caller-gated to prevent the setting from
leaking onto EllesmereUI-owned surfaces. Changes repaint existing main frames
without a reload.

## Inventory character-cache management

The Bags & Inventory page can now remove one cached character or reset all
character-keyed inventory data with confirmation. Individual removal excludes
the logged-in character. Reset All clears character, mail, and auction caches,
then rescans the current character when tracking is enabled; warband and guild
caches remain intact.

## Unified Blizzard Bar Art toggle (retired in v1.1.5)

Forever can hide the two side griffons independently from the central action
bar artwork. FafnyirTools now treats the recovered central background and both
griffons as one feature: enabling **Blizzard Bar Art** restores the complete art
set, while disabling it hides the shared holder and all of that artwork.
The decorative child branches are restored with the griffons; Blizzard's
separate Edit Mode interaction branch, including **Click To Edit**, stays hidden.
The user confirmed this behavior in game on 2026-09-24 with build `68e7a1a`:
the FafnyirTools toggle controls the background and both griffons together and
overrides Blizzard's independent side-art preference.
On 2026-09-25 the user also tested that build on Retail with EllesmereUI 9.2.9
and reported that everything appeared to work correctly. Retail and Forever
were using byte-identical EllesmereUI Action Bars 9.2.9 source during this test.

## 2026-09-24 — Secure reload confirmations

Forever rejects direct addon callback calls to protected `ReloadUI()`. All
FafnyirTools confirmations now use EllesmereUI 9.2.6's `reload = true` popup
contract, which routes the hardware click through a secure `/reload` action.
Import, backup restore, reset, Unit Frame source, and Aura Skins prompts are
covered. In combat the host asks for a manual `/reload`, matching EllesmereUI.

## Blizzard Bar Art persistence repair (historical; retired in v1.1.5)

The v1.1.3 artwork could disappear after runtime action-bar transitions because
it refreshed only at login and on size changes and retained its original
`MainActionBar.BorderArt` and `EndCaps` references. The v1.1.4 line now
reacquires live artwork and restores it after paging, specialization, vehicle,
override, shapeshift, Edit Mode, world-entry, and combat transitions. Hooks also
repair direct hide, alpha, or parent changes. Offline regression coverage passes;
in-game confirmation is still required.

The former fixed `1.06` artwork multiplier is now a saved **Art Scale** slider
from 1.00 to 1.10 in 0.01 steps. Its default remains 1.06 so existing visuals do
not change automatically; the second machine can select 1.01. Because this is a
local display calibration, Global Settings exports deliberately omit it.

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

The v1.1.4 beta line added a Forever-only **Volumetric Fog** toggle under QoL.
That historical implementation stored the choice and reapplied `/console
volumeFog 0|1` at login and world transitions. Blizzard subsequently made the
setting non-persistent, so v1.1.5 hides the control and stops applying it.

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

src/FafnyirTools contains the maintained addon source, including restored PermanentCompanionPet.lua.
The prior QuestXPFixed baseline remains immutable in releases/ and its baseline
tag/fingerprint. Active source now intentionally differs from that baseline.

Restored per-character companion selections, legacy migration, safety checks,
QoL controls, event registrations, v1.0.8-v1.1.1 history and original credits.
Older questXPEnabled/questXPColor preferences migrate only when new keys are
missing. Existing new keys/custom settings take precedence.

Seven pages: About / QoL / Unit Frames / Action Bars / XP & Progression /
Bags & Inventory / Layouts. Unit Frames contains Aura Skins, Resting, name mode,
and the Focus header control. /faftools opens Unit Frames. About uses measured wrapped text height.

## Preservation

This section records the historical consolidated v1.1.2 baseline. Unit Frame
Sources and Blizzard Bar Art were subsequently retired in v1.1.5.

## Validation

Combined offline checks pass: Lua files, TOC/module contracts, seven real
feature pages, existing XP/aura/action-options suites, and companion
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
