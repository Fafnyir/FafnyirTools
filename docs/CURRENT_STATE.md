# Current state — v2.0.0 standalone release, 2026-10-31

## Post-release standalone window resizing test — 2026-11-01

At the user's direction, the native standalone settings window now supports
bounded bottom-right resizing from 760×520 through 1200×850. Its scrollable
content width and three-column option rows recalculate from the resized frame
instead of retaining the original fixed 820-pixel layout. Width and height are
stored under a machine-local `standaloneWindow` record, deliberately excluded
from global settings transfer, and clamped before restoration. The About page
includes a standalone-only Reset Window Size control that restores 920×620.
Offline resize, persistence, reset, localization and full-suite checks pass;
in-game drag feel, extreme sizes, UI scales and Chinese wrapping require the
new test package.

The same follow-up restores the branded addon-list icon. The historical
FafnyirMedia `AddonLogo` path is no longer safe now that FafnyirMedia is
optional, so the TOC points to the equivalent logo bundled at
`FafnyirTools/Media/Logo.tga`; standalone installs therefore retain the icon.

After successful local development and offline validation, the user authorized
the final v2.0.0 release on 2026-10-31. GitHub and CurseForge publication use
the revision-stamped standalone artifact identity `Fafnyir_Tools_v2.0.0_*`.

At the user's direction on 2026-10-31, three author-owned legacy addons are
consolidated into standalone mode. HideTargetRepColor was already represented
by the maintained Target/Focus status-texture handler and remains one shared
implementation. FPSDisplay is now a default-off movable FPS/world-latency
readout with saved local position, font-size control, reset, and the legacy
`/fpsdisplay` shortcut. NicerDamage is now a default-off damage-font switch
using the original Luckiest Guy font and a Reload Now/Later confirmation.
FPS position is deliberately excluded from global transfer while its portable
preferences and the Nicer Damage toggle are included. Both new option modules
remain absent when EllesmereUI is installed. Offline behavior, default,
diagnostics, localization, font-integrity, export-schema and gating checks pass;
in-game standalone rendering and combat text still require confirmation.

The same standalone QoL scope now includes a default-off **Hide Default Tooltip
Health Bar** toggle. It targets only Blizzard's `GameTooltipStatusBar`, uses a
secure post-Show hook and alpha changes rather than protected visibility
mutations, restores full opacity immediately when disabled, and is not
registered when EllesmereUI is installed because EllesmereUI now owns the
equivalent tooltip-strip option. Offline ownership, live-toggle and repeated
Show behavior pass; Retail and Forever hover testing remains required.

The standalone Action Bars page now also has a default-off **Mouseover Action
Bars** feature. It controls Blizzard's primary, seven multi-action, Pet and
Stance bars, Micro Menu and Bag Bar as independent hover groups, with a
separate saved toggle for each bar. A saved Faded Opacity slider ranges
from fully hidden to fully visible; entering a bar or any of its buttons
restores that group to full opacity and leaving reapplies the saved value after
a short boundary delay. Disabling immediately restores every discovered bar to
full opacity. The first disabled-to-enabled transition saves the choice and
shows Reload Now/Later because live enablement was not reliable in game; bar
selection and opacity changes remain live. The implementation changes only frame alpha and hover scripts—no
secure action attributes, clicks, paging or spell state. It is not registered
with EllesmereUI installed. Offline hover/leave/restore and ownership tests
pass; in-game Edit Mode, combat, paging, vehicle and pet/stance testing remains.

Standalone mode now creates a standard circular **Fafnyir Tools minimap
button**. Left-click opens or closes the standalone settings window. Left-drag
moves it around the minimap perimeter and saves its angle locally. That
machine-specific placement is intentionally excluded from global settings
exports. The button is not created when EllesmereUI is installed, avoiding a
duplicate launcher. Offline click, drag, persistence, export exclusion and
ownership tests pass; Retail/Forever minimap rendering still requires in-game
confirmation.

The minimap launcher now uses the user-supplied 512×512 Fafnyir dragon logo,
converted from transparent PNG to a WoW-safe 32-bit alpha TGA. The standard
minimap tracking border and highlight remain in place around the branded icon.

## v2.0.0 test — optional EllesmereUI integration

At the user's direction on 2026-10-31, standalone mode now includes default-off
controls for Blizzard's native Player Rest loop. Enabling the feature permits
horizontal and vertical offsets and optional hiding at effective maximum level.
It snapshots and restores Blizzard's original anchors, reapplies after the
native status updater, and remains absent when EllesmereUI is installed so the
existing EUI Resting integration is unchanged. Offline tests cover defaults,
offsets, max-level visibility, the status hook and restoration; live Retail and
Forever frame discovery and rendering still require in-game confirmation. The
first package incorrectly targeted the retired `PlayerRestIcon` global and its
controls had no visible effect. Current Blizzard source identifies the live
object as `PlayerFrameContentContextual.PlayerRestLoop`; the corrected resolver
and post-update hook now follow that implementation. In-game testing confirms
the corrected offset controls move the native resting animation. The same test
showed that standalone slider thumbs lacked explicit horizontal orientation and
there was no numeric position readout; the shared native slider now declares
horizontal orientation and displays its live value at the right edge. Screenshot
testing then showed the original controls needed clearer feedback. A subsequent
trial expanded the range and split the axes into full-width rows, but in game
that made horizontal adjustment far too coarse and pushed Vertical and Reset
below the visible section. A second screenshot confirmed that the two-column
offset row still failed to render Vertical and the separate Reset row remained
outside the viewport. The corrected layout uses one three-column row for
Horizontal, Vertical and Reset, tightens both axes to -25 through +25, and
retains double-click-to-zero behavior.

The first three-column test screenshot also exposed a standalone navigation
cosmetic defect: QoL content loaded, but the active underline remained on About.
Tab selection now uses one authoritative routine that hides every underline and
shows only the page actually built; tab click closures also bind a stable page
name per iteration. The next screenshot still showed the underline attached to
Action Bars while QoL content was visible, identifying the per-button accent
objects as the remaining failure point. The current correction uses one shared
underline anchored directly to the clicked button and reads the page name stored
on that same button. In-game testing then showed the shared cross-hierarchy
texture did not render at all. The current revision returns to the known-rendering
button-owned accent, but selects it directly from the clicked button rather than
through a page-name lookup. Offline coverage now performs an actual simulated
QoL tab click and requires QoL's accent visible and About's hidden. In game,
every tab except QoL then rendered correctly. The remaining difference was the
accent's reliance on an implicit relative frame; all tab accents now explicitly
anchor both lower corners to their owning button. That produced no in-game
change for QoL, confirming the texture itself was the failing primitive. The
current revision replaces tab underline textures with higher-frame-level child
frames and routes all active styling through each button's `SetSelected` method;
the active label also turns purple as a second unambiguous state cue.

Inspection of the live `General.log` then identified the actual QoL-only cause:
WoW Slider frames reject `OnDoubleClick`, so assigning the proposed axis-reset
handler aborted page construction immediately after Horizontal. Vertical,
Reset, and the final tab-selection pass consequently never ran. The unsupported
handler is removed; the visible Reset button remains the supported reset path.
The same log exposed an obsolete multi-argument `GameTooltip:SetText` call,
which is now reduced to the current safe text-only form. Standalone page builds
are also protected so a future builder failure is reported in chat without
preventing the selected-tab state from finalizing.

The user's 2026-10-31 in-game screenshot from build `30e80ff` confirms the
correction: QoL has the active purple label and underline, and the Native
Resting section renders Horizontal and Vertical sliders, numeric values, Hide
at Max Level and the Reset button. This confirms presentation and construction
in the tested Retail setup; max-level hiding, reload persistence and broader
Forever/combat/vehicle behavior remain separate runtime checks.

At the user's direction after that confirmation, the Horizontal Offset maximum
is extended from +25 to +140 while retaining its -25 minimum. Vertical remains
-25 through +25. Existing saved offset values are preserved.

The user subsequently confirmed that the first disabled-to-enabled transition
needs a UI reload. Enabling Native Resting Controls now saves the toggle and
shows the standard Reload Now/Later confirmation. Disabling, offset changes and
Hide at Max Level remain live and do not request a reload.

At the user's direction on 2026-10-31, this isolated test changes EllesmereUI
and FafnyirMedia from required to optional dependencies. With EllesmereUI
installed, the existing sidebar, widgets and complete integration feature set
remain active. Without EllesmereUI, `/faftools` opens a native movable window
for portable features: About/diagnostics, global settings transfer, Leveling
Forecast, Device Layout, native action-bar right-click self-cast, Retail
companion-pet persistence, and Forever inventory tracking.

Resting, Target Aura Skins, Focus Header, Icon History Border, BigWigs Border,
click-only Center Reticle and Shared Artwork remain EllesmereUI integrations and
are intentionally not registered in standalone mode. Their saved values remain
untouched. The standalone window supplies native buttons, toggles, input boxes,
sliders and compact click-to-cycle selectors; it does not imitate EllesmereUI
frames or write another addon's settings.

Offline validation passes for the existing integration tests and the new
standalone dependency, gating and Blizzard action-button contract. Native
Retail/Forever rendering, settings interaction, popup behavior and action-bar
combat safety still require in-game testing. This test is not published and
does not alter the confirmed v1.x release line.

The first in-game standalone screenshot confirmed that the native window opens
and renders without EllesmereUI. At the user's direction, the follow-up test
replaces the stock Blizzard presentation with the established Fafnyir palette,
custom flat controls and pixel borders, reduces and scales the window, and uses
the SharedMedia font named `- THE FONT` when available from FafnyirMedia. It
falls back to Blizzard's standard font when that optional addon or media entry
is absent. The skinned revision awaits in-game confirmation.

The first skin rendered correctly but the user was not satisfied with its
uniform bright-blue treatment, oversized empty header and lavender selected
tab. Trial 2 fixes the hidden title by parenting header text above its surface,
reduces the window/header/sidebar and row spacing, limits bright borders to
subtle accents, uses darker controls with hover color, and marks the selected
page with a slim secondary-color bar. Trial 2 awaits in-game confirmation.

The user then supplied Naowh Smart Reminders as the preferred visual reference
and requested its blue accent be replaced by `#6358B8`. Trial 3 adopts that
structure for the standalone window: charcoal title and tab bars, horizontal
page tabs with a purple active underline, dark row panels with center dividers,
grey control outlines, white text and purple section/control accents. It keeps
`- THE FONT` and does not alter EllesmereUI's own options. Trial 3 awaits
in-game confirmation.

The first Trial 3 companion-pet screenshot showed toggle labels sitting above
their 22-pixel checkboxes because the labels used a 36-pixel top-justified text
box. The correction vertically centers a 22-pixel label on each checkbox and
adds a consistent six-pixel gap in both option columns. In-game confirmation of
the corrected alignment is confirmed by the user's 2026-10-31 screenshot from
build `16dd10c`.

The user subsequently tested the v2 branch with EllesmereUI installed and
reported that all functionality works with no errors. This confirms the
optional-dependency path preserved the complete integration surface in the
tested setup; exact client and feature-by-feature scenario coverage were not
supplied, so it is not an exhaustive Retail/Forever matrix.

## v1.1.20 — Leveling Forecast refresh test

At the user's direction on 2026-10-31, the existing read-only Leveling Forecast
now includes a Refresh button. The button asks EllesmereUI to rebuild the
current options page, which reruns the forecast calculation immediately without
requiring the page to be closed and reopened. It adds no quest/XP events,
background polling, saved setting, or XP-bar behavior.

English plus first-pass Simplified and Traditional Chinese strings are included;
the Chinese wording remains pending Yilang's fluent review. All offline checks
passed, and the user reported on 2026-10-31 that test build `2184a77` passes
in-game testing. The client and individual refresh scenarios were not supplied,
so this confirms the tested setup rather than an exhaustive Retail/Forever
matrix.

## v1.1.19 — EllesmereUI 9.7 ownership cleanup

At the user's direction on 2026-10-30, three overlapping integrations were
retired or narrowed after comparing the installed EllesmereUI 9.7 source and
public release history. The Retail Flyout Fix is removed completely. Retail now
leaves offline character inventory and item-count tooltips to EllesmereUI Bags;
Fafnyir Tools retains that feature on Forever. Forever now leaves persistent
companion-pet summoning to EllesmereUI Forever Essentials; Fafnyir Tools retains
its companion feature on Retail.

The old `flyoutFix`, `inventory`, and `permanentCompanionPet` SavedVariables are
not deleted or rewritten during an ordinary upgrade. Flavor guards run before
feature registration, so the delegated feature has no options, scanners,
summoning callbacks, or diagnostics entry on that client. Core event
subscriptions are also flavor-scoped. Offline validation passes. The user
reported that test build `8247f07` completed in-game testing without errors and
authorized the v1.1.19 release on 2026-10-30. Detailed client-by-client scenario
coverage was not supplied, so the report is confirmation rather than an
exhaustive Retail and Forever matrix.

Final workflow `41121846000` published GitHub release `release/v1.1.19` from
commit `b96476f`. The revision-stamped artifact is
`Fafnyir_Tools_for_EllesmereUI_v1.1.19_b96476f.zip` with SHA-256
`8f5bc4a731bbcbc4c5a845eb6fde3abfc1ae96bd08f7a49750a18b94d02c94a5`.
CurseForge accepted the same ZIP as Release file `9376718`; moderation and
public availability remain separate from upload acceptance.

## v1.1.18 — Chinese localization completion

Promotes the two post-v1.1.17 localization integrations into a maintenance
release. Yilang reviewed all 12 Leveling Forecast strings and all 11 BigWigs
Border, Content Spacing and click-only Center Reticle strings. Both `zhCN` and
`zhTW` now cover all 187 current English interface keys. This release changes
no feature behavior, defaults, saved settings or dependency ownership.

The user authorized the v1.1.18 release on 2026-10-23. Full offline validation
passed and final workflow `40025945048` published GitHub release
`release/v1.1.18` from commit `8bb4731`. The revision-stamped artifact is
`Fafnyir_Tools_for_EllesmereUI_v1.1.18_8bb4731.zip` with SHA-256
`2a427498f18cd35786d1c69020979ff507d5901e4c72bf026629b1dd32e77406`.
CurseForge accepted the same ZIP as Release file `9302478`; moderation and
public availability remain separate from upload acceptance.

## v1.1.17 — BigWigs Border test

Adds a default-off QoL toggle for all borders returned by EllesmereUI on BigWigs
timer bars and their attached spell icons, with Pixels as the default. It uses public BigWigs creation/emphasis
messages, does not alter BigWigs profiles, and excludes nameplate icons. The
six new Simplified and Traditional Chinese strings are included as first-pass
translations pending Yilang's review. Offline validation passes; in-game BigWigs
test bars and combat behavior remain to be confirmed. The initial border passed
in-game testing; a subsequent screenshot showed the icon and bar outlines
overlapping, so the revised test adds a saved 0–10 pixel Content Spacing slider.
After that build exposed text overlap, the implementation was changed to
preserve each active BigWigs bar style's real anchors instead of rebuilding a
generic LibCandyBar layout. This style-safe revision awaits in-game testing.
The latest revision leaves the spell icon and its BigWigs indicators fixed and
moves the complete bar body instead.
The selected border now also applies to BigWigs' four pooled normal Messages
icons and follows their visibility/fade alpha; message text is not repositioned.
The shared Content Spacing slider also separates message icons from their text;
zero or disabling restores native anchors for both bars and messages.
User in-game testing on 2026-10-18 confirms build `233c90c` works, including
the global Messages-frame discovery that superseded two failed scan attempts.
The first dropdown repair queued a full EllesmereUI page rebuild after Border
Style changes. In-game video showed that this still left the closed caption and
selected-row highlight stale. That rebuild has now been removed: it recycled
the dropdown before EllesmereUI's own post-selection label/menu refresh could
finish. The new test build leaves that native dropdown lifecycle intact while
still applying the border immediately. A second in-game recording showed the
native refresh alone was also insufficient, and the direct-control build still
failed while also leaving the feature impossible to re-enable after disabling.
The current revision removes the enable switch's unnecessary BigWigs-loaded
lock and rebuilds the page 0.05 seconds after either control changes, allowing
the active click/menu lifecycle to finish before the saved state is repainted.
In-game testing then showed the toggle value persisted correctly but that page
rebuild interrupted its visual animation, leaving an enabled value drawn as
off until reload. The toggle path now refreshes existing widgets without a page
rebuild; only the dropdown retains the delayed repaint.
That widget-list refresh still left the switch visually off after an off/on
sequence. The current test removes all external refreshes from the toggle
setter and leaves Border Style selectable while disabled, so EllesmereUI alone
owns the switch animation and no dependent control requires live disabling.
That still reproduced in game, identifying the synchronous live
`feature:Refresh()` call as the remaining common work inside both broken
controls. Toggle and Border Style changes now save normally and show the
standard secure Reload Now/Later confirmation instead of restyling active
BigWigs frames during the click. Content Spacing remains live-adjustable.
The user confirmed test build `ee4fc67` works perfectly in game on 2026-10-18.
This accepts the reload-applied toggle and Border Style behavior as the stable
v1.1.17 design; broader BigWigs combat/style coverage remains separate.

## v1.1.17 — Click-only Center Reticle test

Adds a default-off QoL toggle for EllesmereUI's Center Reticle. When the native
reticle is enabled, FafnyirTools shows only its center dot while the left or
right mouse button is held. The native cursor circle remains under EllesmereUI
control, including its size, color, opacity and visibility rules. FafnyirTools
does not write EllesmereUI's saved reticle preference and restores native
behavior immediately when the enhancement is disabled. The setting participates
in reset, diagnostics and global settings transfer. English plus first-pass
Simplified and Traditional Chinese strings are included. Offline validation
passes; mouse-down/up behavior still requires in-game confirmation.
The first test build `1bea7c9` incorrectly looked for
`_ECL_AceDB.profile.cursor.reticle`; EllesmereUI publishes a narrow cursor DB
view where `profile` already is the cursor table. The corrected build reads
`_ECL_AceDB.profile.reticle`, matching EllesmereUI's own options helper.
The user confirmed corrected build `de4f128` works perfectly in game on
2026-10-18 and explicitly approved the addition. This confirms native-reticle
detection plus click-only visibility under the tested setup; broader combat and
locale layout checks remain separate.

The user authorized the final v1.1.17 release on 2026-10-18 after confirming
both the reload-applied BigWigs controls and corrected click-only reticle.

Final release workflow `39179757630` completed successfully on 2026-10-18.
GitHub release tag `release/v1.1.17` points to source commit `984b0f5`; the
published artifact is
`Fafnyir_Tools_for_EllesmereUI_v1.1.17_984b0f5.zip` with SHA-256
`1aeed6b9b605d67855552f988190427073350133745446e285c4e79a100dbc0f`.
CurseForge accepted the same revision-stamped ZIP as file `9251085`.

On 2026-10-19, Yilang returned the Leveling Forecast localization worksheet.
All 12 `zhCN` and `zhTW` strings passed key, placeholder, completeness and Lua
validation and were integrated into the active locale files. Both Chinese
locales now cover all 187 current English interface keys. This source change is
post-release and has not been published as a new package.

On 2026-10-23, Yilang returned the v1.1.17 localization supplement covering
all 11 BigWigs Border, Content Spacing and click-only Center Reticle strings.
Five strings in each locale received wording or typography changes; the other
six were returned unchanged. The complete returned wording is integrated and
passes locale completeness, placeholder, fallback and Lua validation. These
post-release localization changes have not been published as a new package.

## v1.1.16 — Leveling Forecast to 90

The completed-quest projection now walks the Midnight 12.1 XP requirements from
the player's current level through level 90. The live `UnitXPMax()` value is
still authoritative for the current level; future requirements are used only
when that value matches the bundled curve. If Blizzard changes the curve, the
display safely returns to the v1.1.15 one-level overflow result instead of
presenting a false precise forecast.

The reported screenshot case is covered directly: level 81 at 418,117 of
423,390 XP plus 604,313 completed-quest XP projects to level 83 at about 33.6%.
Tests also cover reaching level 90 and the stale-curve fallback. The two long
guidance messages now occupy separate full-width rows to prevent overlap.
Offline validation passes. On 2026-10-18 the user supplied an in-game screenshot
from test build `b72b994` confirming the reported case displays **Level 83 —
33.6%** and that the two guidance messages render on separate rows without
overlap. Exact-boundary, additional multi-level and level-90 scenarios remain
pending. The test package is built; final publication is authorized and pending.

After reviewing the confirmed in-game result, the user explicitly authorized a
final v1.1.16 release on 2026-10-18 because the multi-level projection is more
closely aligned with the original feature goal.

Published final GitHub release `release/v1.1.16` at `666ff7f` through workflow
`39131249304`. ZIP/display name:
`Fafnyir_Tools_for_EllesmereUI_v1.1.16_666ff7f.zip`. SHA-256:
`fa7d88eb1f02c007bd2ea5dca9047c5027094c635c03c3f5c3a19b4687f06e7a`.
CurseForge accepted Release file `9239813`; moderation/public availability is
separate from upload acceptance.

## v1.1.15 — Leveling Forecast

QoL now includes a read-only Leveling Forecast. It sums unique completed quests
currently ready to turn in through `GetQuestLogRewardXP(questID)`, compares the
adjusted and base totals to report the effective applicable quest-XP bonus, and
projects the player's progress after those turn-ins. Forecasts within the
current level are exact from the client values. If rewards cross the next level,
the panel reports the next level plus overflow and labels it with `+` rather
than estimating later levels from an unstable XP table.

The feature does not create or alter XP bars, subscribe to XP/quest events,
write settings, or enter global transfer. EllesmereUI retains complete XP-bar
ownership. The panel recalculates whenever the QoL page is opened; close and
reopen it to refresh. Offline tests cover duplicate quest IDs, completed-only
selection, adjusted/base bonus math, within-level and overflow projections,
maximum level, secret values, missing APIs and absence of XP-bar operations.
The user reported “Testing passes” on 2026-10-18 and explicitly authorized the
final release. The client, EllesmereUI version and individual scenarios tested
were not supplied, so this is confirmation rather than an exhaustive matrix.
New strings use English fallback pending reviewed Chinese translations.

Published final GitHub release `release/v1.1.15` at `5c91d53` through workflow
`39126509465`. ZIP/display name:
`Fafnyir_Tools_for_EllesmereUI_v1.1.15_5c91d53.zip`. SHA-256:
`9ff852cb55eb1779a3abccad2ccfa85e4175178246c84a1870f528b3184fa107`.
CurseForge accepted Release file `9239256`; moderation/public availability is
separate from upload acceptance.

## v1.1.14 — Chinese localization

FafnyirTools now includes complete Simplified Chinese (`zhCN`) and Traditional
Chinese (`zhTW`) locale files with English fallback. Volunteer translator
**Yilang** supplied all 164 strings and returned seven final wording refinements
(six `zhCN`, one `zhTW`), which were checked for Lua syntax, key parity,
nonblank values and placeholder compatibility before integration. Yilang is
credited on the About page and in the release notes with thanks for the support.

The unsuccessful developer locale-override experiment is absent. Locale choice
follows the WoW client normally. Offline validation passes; the release workflow
passed and published the final release on 2026-10-16.

Published final GitHub release `release/v1.1.14` at `7acd694` through workflow
`38965194915`. ZIP/display name:
`Fafnyir_Tools_for_EllesmereUI_v1.1.14_7acd694.zip`. SHA-256:
`935a3fc13ba5110b509587609160e6c7c10071eb532f4f744ec03c837461e04e`.
CurseForge accepted Release file `9213901`; moderation/public availability is
separate from upload acceptance.

## Chinese localization test build — in-game validation pending

The volunteer returned final Simplified Chinese (`zhCN`) and Traditional
Chinese (`zhTW`) translations for all 164 worksheet strings on 2026-10-16.
The submitted workbook is preserved under `docs/localization/` and its text is
integrated through English fallback plus dedicated locale files. Active page
names, controls, tooltips, dialogs, dropdown values, chat feedback and inventory
tooltip labels use the locale layer; saved values and internal feature keys stay
language-neutral. Historical About changelog text, credits, the privacy-safe
support diagnostics body and a few dynamic sentences outside the worksheet
remain English in this first pass.

Offline checks cover Lua 5.1 syntax, TOC ordering, identical 164-key locale
sets, nonblank values, `%d` formatting, unsupported-locale English fallback and
all existing feature regressions. Chinese-client font coverage, wrapping,
control widths and live options behavior are not yet confirmed in game. Source
This work is released as v1.1.14.

The local Retail installation does not expose Chinese text languages and the
Forever client reverts its language selection to English, so native testing is
being handed to translator **Yilang** on a Chinese client. The unsuccessful
developer locale-override experiment has been removed from this test build.

## v1.1.13 — Retail 12.1.5 compatibility

The active TOC now includes Retail interface `120105`, matching the installed
EllesmereUI 9.5.4 metadata. Existing Retail interface entries and Forever
interface `16001` remain supported. This is a metadata-only compatibility
change: addon behavior, defaults and saved settings are unchanged. Offline and
in-game validation of the new package remain separate. The user explicitly
authorized a final GitHub and CurseForge release on 2026-10-14.

Published final GitHub release `release/v1.1.13` at `9fece5e` through workflow
`38547034451`. ZIP/display name:
`Fafnyir_Tools_for_EllesmereUI_v1.1.13_9fece5e.zip`. SHA-256:
`667a72c3ae97cdeb31e09c8d5a863f5ea8fb27edd73775be131a76fe36e1948e`.
CurseForge accepted Release file `9171398`; moderation availability is separate.

## v1.1.12 — Resting indicator placement

The Resting Indicator now provides a Left / Right dropdown under Unit Frames.
Right remains the upgrade-safe default, and existing settings gain it only when
missing. Left anchors the animation to the Player frame's upper-left corner;
Right retains the existing upper-right anchor. Horizontal offsets are mirrored
across sides so the same saved value provides matching corner spacing. The
setting participates in reset and the existing allowlisted global export/import.
Offline validation covers defaults, both anchors, mirrored positive and negative
offsets, invalid-value fallback and reset. In-game appearance and persistence
were confirmed by the user on 2026-10-11 with test build `23df736` (“Tests
fine”). Client/EllesmereUI versions and the detailed scenarios exercised were
not supplied. The user explicitly authorized a final GitHub and CurseForge
release.

Published final GitHub release `release/v1.1.12` at `72bc275` through workflow
`38178412230`. ZIP/display name:
`Fafnyir_Tools_for_EllesmereUI_v1.1.12_72bc275.zip`. SHA-256:
`eafeace51ed84930439ad8e71067929be776969031a699ebaea87e09f6db718d`.
CurseForge accepted Release file `9139664`; moderation availability is separate.

## v1.1.11 — EllesmereUI owns name formatting

Published final GitHub release `release/v1.1.11` at `6e54117` on 2026-10-08.
Workflow `37866234202` passed validation, packaging and publishing. ZIP/display
name: `Fafnyir_Tools_for_EllesmereUI_v1.1.11_6e54117.zip`.
SHA-256: `ac5bfdeb36078fae70a60c27242ca74b280a7893ddae686500f8792230be6659`.
CurseForge accepted Release file `9103690`; moderation availability is separate.

The user reported that EllesmereUI now supports name formats on all frames and
requested removing the redundant FafnyirTools implementation. The
`UnitFrameNames` module, Forever-only First/Last/Whole dropdown, default,
options registration, global-settings schema and runtime `WithSurname` wrapper
are retired. Existing `unitFrameNames` SavedVariables remain untouched as
unknown data during ordinary upgrades and settings transfers. Offline
retirement and preservation coverage passes; confirm in game that the option is
absent and EllesmereUI formats all desired frames without interference.
User explicitly authorized **Push release** to GitHub and CurseForge.

## v1.1.10 release, 2026-10-06

## v1.1.10 — XP module retired, 2026-10-06

Published final GitHub release `release/v1.1.10` at `39f45e3` on 2026-10-06.
Workflow `37450710563` passed validation, packaging and publishing. ZIP/display
name: `Fafnyir_Tools_for_EllesmereUI_v1.1.10_39f45e3.zip`.
SHA-256: `4b31ff09e57ba15617fc1d7b0f920ea8828ec8de56e894aaadcc9322fed59abb`.
CurseForge accepted Release file `9079045`; moderation availability is separate.

User requested removing the remaining XP bar feature after EllesmereUI added
quest XP. Installed Forever source exposes ApplyXPQuestOverlay with incomplete
and completed quest layers. Removed module, XP & Progression page, defaults,
legacy migration, export/import schema, diagnostics and XP/quest-only events.
PLAYER_LEVEL_UP remains for Resting. Legacy xpBar data survives upgrades and
settings transfer unchanged. All offline checks pass; in-game confirmation of
this removal is pending. User explicitly authorized **Publish v1.1.10 final** to GitHub and CurseForge.
No additional in-game confirmation was supplied before this release request.


## v1.1.9 — 2026-10-05 XP ownership cleanup

Published final GitHub release `release/v1.1.9` at `a03f221` on 2026-10-05.
Workflow `37380110342` passed validation, packaging and publishing. ZIP/display
name: `Fafnyir_Tools_for_EllesmereUI_v1.1.9_a03f221.zip`.
SHA-256: `a1a9296d28f11d81238e61b24c8699fc89a308e9a4fa816cc760ed39d8ff2c31`.
CurseForge accepted Release file `9073735`; moderation availability is separate.

Current XP gradients now belong to EllesmereUI. Installed Forever source exposes
`XPBarGradient` and ARTWORK current/rested layers 4/2. FafnyirTools keeps rested
gradients and completed Quest XP at layer 3; rested styling no longer depends on
the retired current-gradient enable flag. Legacy current-gradient saved settings
survive initialization/reset/import but are excluded from exports and diagnostics.
Rested direction remains saved under orientation. Offline tools/check.py passes,
including native-current preservation, independent rested styling, reset and
settings transfer. User confirmed “Looks and tests fine” with test build afd5d0c and a screenshot
showing current, quest and rested segments on 2026-10-05. Client/EUI versions
and detailed test scenarios were not supplied. User explicitly authorized
**Publish v1.1.9 final** to GitHub and CurseForge.


## v1.1.8 — XP layering

Published 2026-10-04: final GitHub release `release/v1.1.8` at `5ccee4d`.
Workflow `37234323679` passed validation, packaging and publishing. ZIP and
display name: `Fafnyir_Tools_for_EllesmereUI_v1.1.8_5ccee4d.zip`.
SHA-256: `a525abef5c072d303d6026310f94129041f78444448fcba870c890f07bded6d6`.
CurseForge accepted Release file `9063152`; moderation availability is separate.

User requested Current XP / completed Quest XP / Rested XP from front to back
after a Forever screenshot showed rested XP covering the quest segment.
Quest XP now uses ARTWORK sublevel 3, between native Current XP at 4 and Rested
XP at 2. Quest XP retains its current-XP starting point, level-boundary clipping
and saved settings. All offline checks pass, including layer-order assertions;
user confirmed the new appearance with test build `aa4b028` on 2026-10-04
and authorized **Publish v1.1.8 final** to GitHub and CurseForge. Detailed
scenario coverage remains separate.


## v1.1.7 SharedMedia artwork

2026-10-03: user authorized v1.1.7 as a final GitHub/CurseForge release after
confirming arrows and Party/Raid role icons. Version, About history, changelog
and release notes are updated together. Offline checks pass; detailed manual
QA omissions remain listed below.

Published 2026-10-03: final GitHub release `release/v1.1.7` at `e744c79`,
with revision-stamped ZIP and build manifest. Workflow run `37142374350`
passed offline validation, packaging and publishing; CurseForge accepted the
Release upload as file `9049889`. ZIP SHA-256:
`d417f01795c9781b203e680947a845b4a6f2d591e3c9bec44d8f45f41dd2246c`.
CurseForge upload acceptance does not establish moderation/public availability.


2026-10-03: Unit Frames now includes a **Nameplate Target Arrow** SharedMedia
selector and **FafnyirMedia Party / Raid Role Icons** toggle. Both default to
native EllesmereUI artwork. The selector lists SharedMedia `background` entries whose names contain `arrow`,
including FafnyirMedia's
`- Arrow Glow`. Party/Raid roles fetch `- Tank`, `- Healer` and `- DPS` from that
same category, with the existing image paths as a fallback for older media
versions. Neither dependency is modified. The registered `- Combat` image is
not applied to combat indicators in this scope.
Arrows retain EUI visibility, scale, color and position; missing media falls
back to native artwork without discarding the saved selection. Role artwork
only replaces already-visible Party/Raid icons after EUI renders them; role
filters, hide-in-combat, size and placement remain native. Extra frames and
main unit frames are excluded. Turning either override off restores native
artwork. Preferences are included in global export/import and diagnostics.
The installed Retail/Forever sources expose matching integration hooks.
`tools/check.py` passes all offline suites, including new lifecycle, restoration,
secret-value, scope and settings-transfer coverage. In-game appearance,
pool reuse and combat behavior remain unverified.

2026-10-03 follow-up: user confirmed arrows work in game with build `8def225`.
Client/EUI versions and specific scenarios were not supplied. The arrow selector
now excludes non-arrow backgrounds, including Tank, DPS, Healer and Combat.
Existing excluded selections are preserved but render native arrows; role
artwork remains separately available for Party/Raid. Offline checks pass.

2026-10-03 in-game report, current SharedMedia artwork task: user confirmed the
role-icon toggle works in Party. Raid has explicitly not been verified yet.
The tested package revision, client/EUI versions and specific role/combat/reload
scenarios were not supplied; this confirms Party toggle behavior only.

2026-10-03 subsequent report, current SharedMedia artwork task: user also
validated role icons in Raid. Party and Raid role artwork now have user
in-game confirmation. Tested package revision, client/EUI versions and detailed
combat/reload scenarios remain unspecified; no broader regression claim is made.

Other media addons can register `targetarrow` entries through LibSharedMedia:
a string path supplies a right-pointing image placed at the left of the plate
and mirrored on the right; a table `{ left = fullPath, right = fullPath }`
supplies independent images. The selector lists registered entries when the
page builds; reopen the page to list newly registered artwork. No filesystem
scanning or automatic discovery of unregistered image files is implied.

The About page now provides **Copy Diagnostics**. It opens EllesmereUI's native
copy popup with a plain-text report containing FafnyirTools, client,
EllesmereUI and FafnyirMedia versions; Retail/Forever flavor; interface/build;
options-registration and SavedVariables compatibility state; and the enabled
state of supported FafnyirTools features. The report deliberately excludes
character, realm, account and raw SavedVariables data. If the copy popup is not
available, the same report is printed to chat. Offline report, privacy and
popup-path coverage passes; the options placement and copy interaction require
in-game confirmation.

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

2026-10-03 filename correction: use the exact packaged ZIP basename
`Fafnyir_Tools_for_EllesmereUI_(version)_(commit).zip` for GitHub release titles
and CurseForge display names as well as uploaded filenames. The former friendly
display name obscured the correctly named artifact. The repair workflow changes
only existing release metadata; it does not rebuild or replace ZIPs.

Repair run `37142783967` succeeded on retry after an initial CurseForge HTTP
500. GitHub title and CurseForge file `9049889` display name now match
`Fafnyir_Tools_for_EllesmereUI_v1.1.7_e744c79.zip`. Original ZIP bytes and
release tag remain intact. The complete offline suite, including display-name
metadata checks, passed before the workflow fix was pushed.
