# Reconciled decisions

## 2026-10-18 — BigWigs border test

The user requested a test build with translations for an optional Pixels border
on BigWigs bars and icons. Add one default-off QoL toggle, style only timer bars
and their attached spell icons through BigWigs' public callbacks, and do not
write BigWigs profiles or alter its native nameplate-border controls. Include
AI-drafted Simplified and Traditional Chinese strings in the test build and
keep them marked for Yilang's fluent review.

After the first in-game pass, the user confirmed the border works but showed
the icon and bar outlines overlapping at their shared edge. Add a saved 0–10
pixel spacing slider with an upgrade-safe default of zero. Apply it only
while this border feature is enabled and restore BigWigs' native icon layout
when disabled.

The first offset implementation rebuilt generic LibCandyBar anchors and caused
the active BigWigs style's text spacing to overlap. Replace it before the next
test package: snapshot the actual style-provided icon and status-bar anchors,
adjust only their horizontal seam, and restore those exact anchors at zero or
when disabled.

The next screenshot showed BigWigs indicators positioned beside the spell icon.
Keep the icon and indicators at their native anchors and move the complete timer
bar body instead, carrying its label, duration and style-relative elements with
it. The user also requested parity with Icon History: populate a Border Style
dropdown from EllesmereUI's live border list and retain Pixels as the default.

The user then identified that BigWigs Messages icons use a separate display
path. Extend the same toggle and selected border style to the four pooled normal
message icons. Follow their visibility and fade alpha without moving message
text or changing the BigWigs profile.

## 2026-10-18 — Extend Leveling Forecast through level 90

The user requested that the completed-quest projection continue through level
90 after v1.1.15 stopped at the first level boundary. Supersede the earlier
one-level-only decision for Midnight levels 80–90. Keep the live current-level
`UnitXPMax()` value authoritative and use bundled future requirements only when
that value matches the Midnight 12.1 curve. Fall back to the conservative
one-level overflow result when it does not match. Keep the feature read-only and
move its two long guidance messages to separate full-width rows.

After confirming the level 83 at 33.6% result in game, the user authorized a
final v1.1.16 GitHub and CurseForge release on 2026-10-18. The remaining manual
boundary scenarios are useful follow-up coverage rather than a release blocker.

## 2026-10-18 — Chinese translation worksheet workflow

For new interface strings, prefill localization worksheets with a complete
first-pass `zhCN` and `zhTW` translation when practical. Preserve formatting
tokens exactly and mark all AI-drafted entries **Needs Review**. Translator
Yilang, or another fluent reviewer, verifies official WoW terminology, natural
phrasing and in-game fit before the text is treated as approved or integrated.

## 2026-10-17 — Leveling Forecast test scope

The user authorized a v1.1.15 test build for estimated leveling from completed
quest XP and applicable bonuses such as Warband Mentored Leveling. Implement it
as a read-only QoL panel and preserve EllesmereUI's complete XP-bar ownership.
Use Blizzard-adjusted and base quest reward values to derive one effective bonus
without identifying or double-counting individual buffs. Forecast exactly only
through the current level; crossing the boundary must show next-level overflow
instead of using a hard-coded future XP table. Reopening the page refreshes the
values, avoiding new XP/quest event subscriptions.

2026-10-18: the user reported that testing passes and explicitly authorized a
final v1.1.15 release. Retain the read-only scope and publish through the
configured GitHub/CurseForge workflow. The new forecast strings may use English
fallback until reviewed Chinese translations arrive.

## 2026-10-16 — Chinese localization source

The user identified the returned worksheet as the final volunteer submission.
Treat its complete `zhCN` and `zhTW` columns as the authoritative translation
text for the first localization pass; do not machine-edit wording or silently
normalize brand terminology. Preserve the submitted workbook and keep version
v1.1.13 while producing an in-game test build. Runtime integration translates
display text only, with English fallback and neutral internal or saved keys.
The translator is **Yilang** and must receive visible credit. On 2026-10-16 the
user requested removing the unsuccessful developer locale override and sending
a normal locale-driven test build to Yilang instead.

After Yilang returned six `zhCN` and one `zhTW` wording refinements, the user
explicitly authorized incorporating them and publishing a release. Ship this as
v1.1.14 because the v1.1.13 release tag already exists. Thank Yilang visibly in
the About page and release notes.

## 2026-10-14 — Chinese localization preparation

Prepare a language-neutral volunteer worksheet while waiting to learn whether
the translator supports `zhCN`, `zhTW` or both. Keep the two locales separate,
request official WoW-client terminology, and do not add runtime localization or
machine-generated translations before reviewed volunteer text is available.
Defer historical About changelog prose and the English diagnostics body from
the first translation pass.

## 2026-10-14 — Retail TOC interface update

Add interface `120105` to FafnyirTools after the user requested a TOC update
and the installed EllesmereUI 9.5.4 TOC confirmed that interface. Preserve all
existing interface values, including Forever `16001`. The first test build kept
v1.1.12; the subsequent explicit release request authorizes v1.1.13 and final
publication to GitHub and CurseForge.
Workflow `38547034451` published final GitHub release `release/v1.1.13` at
`9fece5e` and CurseForge accepted file `9171398`.

## 2026-10-11 — Resting indicator side

Add Left / Right placement for the Player-frame resting Z's in v1.1.12. Keep
Right as the upgrade-safe default. Mirror the horizontal offset when rendering
on the left so one saved spacing value produces symmetric corner placement.
Include the recognized setting in reset and global settings transfer.
On 2026-10-11 the user reported that build `23df736` tests fine and explicitly
authorized a final release to GitHub and CurseForge.
Workflow `38178412230` published final GitHub release `release/v1.1.12` at
`72bc275` and CurseForge accepted file `9139664`.

## 2026-10-08 — Retire FafnyirTools name formatting

The user reported that EllesmereUI now supports name formats on all frames and
requested **Build it**. Remove the FafnyirTools `UnitFrameNames` module,
Forever-only option, defaults, export/import schema, reset behavior and runtime
wrapper. Preserve existing legacy `unitFrameNames` SavedVariables as unknown
data during ordinary upgrades and settings transfers. EllesmereUI is the sole
owner of name formatting for v1.1.11.
On 2026-10-08 the user explicitly authorized **Push release**; publish v1.1.11
as a final GitHub and CurseForge release.

## 2026-10-06 — Retire all FafnyirTools XP ownership

Current task user request: EllesmereUI now provides quest XP, so remove our XP
bar option altogether. Retire the whole module and empty XP & Progression page,
including rested styling, quest overlays, defaults, migrations, events, exports
and diagnostics. Preserve legacy SavedVariables untouched. This supersedes the
previous FafnyirTools XP rendering and taxonomy requirements.
On 2026-10-06 user explicitly authorized **Publish v1.1.10 final** to GitHub
and CurseForge.

2026-10-05 public patch-note preference: omit “User confirmed” and testing
commentary from public notes. Keep verification evidence in internal records.


## 2026-10-05 — Native current XP gradient ownership

User requested retiring the duplicate current XP gradient after EllesmereUI added
native support (current task: “Do it.”). Remove FafnyirTools current gradient
controls, runtime writes, defaults, exports and diagnostic state. Preserve legacy
saved keys untouched. Keep rested gradient/colors/direction and completed Quest
XP independent, with Current / Quest / Rested ARTWORK layers 4/3/2. Initial test build stayed v1.1.8. On 2026-10-05 the user confirmed it
looks and tests fine and explicitly authorized **Publish v1.1.9 final** to
GitHub and CurseForge.


## XP layering revision

2026-10-04 release decision: after confirming test build `aa4b028`, user
explicitly selected **Publish v1.1.8 final** to GitHub and CurseForge.

2026-10-04, current XP layering task: user explicitly approved Current XP /
completed Quest XP / Rested XP from front to back so completed quest rewards
remain visible while rested XP fills the remaining bar. This supersedes the
v1.1.5 rested-over-quest decision. Use ARTWORK sublevels 4/3/2; preserve quest
geometry, saved settings and EllesmereUI border/text ownership.


## SharedMedia arrows and FafnyirMedia role artwork

2026-10-03, current feature task: user authorized a FafnyirTools target-arrow
selector under Unit Frames and adding FafnyirMedia role artwork. User clarified
role scope as **Party/Raid only for now**. Preserve native EUI settings and
artwork by default; apply runtime texture overrides without editing installed
EllesmereUI or FafnyirMedia. User subsequently reported all five FafnyirMedia images
registered as SharedMedia backgrounds: `- Arrow Glow`, `- Combat`, `- Tank`,
`- DPS`, `- Healer`. Consume those registrations directly; also support a
custom `targetarrow` category for external paired artwork. Combat-indicator
replacement is outside this request. Keep the current v1.1.6 development version.

2026-10-03 follow-up: user confirmed arrows work and requested role icons be
excluded from target-arrow choices. Filter background names for `arrow`; keep
dedicated `targetarrow` entries and existing Party/Raid role handling.

2026-10-03 release decision, current task: user explicitly selected
**Publish v1.1.7 final** because v1.1.6 already exists. Publish through the
configured GitHub workflow to GitHub and CurseForge.

## GitHub release automation

2026-10-03: releases may be built through the private repository's manually
triggered GitHub Actions workflow. The operator must confirm the TOC version and
choose Draft, Prerelease, or Final; Draft is the safe default. The workflow
reuses `tools/package.py`, creates `release/<version>`, uploads the ZIP and build
manifest, and refuses to overwrite an existing release tag. Offline automation
does not replace in-game validation.

2026-10-03: the same workflow also publishes the verified ZIP to CurseForge
project `1640881` for Prerelease and Final runs. Prerelease maps to CurseForge
Beta and Final maps to Release; Draft never uploads to CurseForge. The API token
is kept only in the `CURSEFORGE_API_TOKEN` GitHub Actions secret.

## Right-click self-cast event ownership

2026-10-02: remove FafnyirTools subscriptions to `ACTIONBAR_SLOT_CHANGED` and
`UPDATE_BINDINGS`. The secure `type2="action"`, `action2=nil` setup follows the
button's current action without rewrites. The former event path could enqueue
one 180-button refresh per high-frequency action-slot notification and was
reported to cause severe frame drops while modifier keys were held.

## Party and Raid name controls retired

2026-09-30: remove Party and Raid frame support from FafnyirTools First Name /
Last Name / Whole Name modes because EllesmereUI now provides those controls.
Keep the existing saved mode and main-unit-frame behavior. Party, Raid and
Nameplates must remain outside the FafnyirTools formatter.

## Damage Meter Icon History border

2026-09-28: add a dedicated persistent **Enable Icon Border** toggle under
FafnyirTools QoL for EllesmereUI Damage Meter Icon History. Keep it off by
default and pair it with a dropdown built from EllesmereUI's complete live
border registry; Pixels is the initial selection. This supersedes the first
inheritance-only trial and the subsequent fixed-Pixels/default-on trial.

## EllesmereUI-owned features retired

2026-09-28: remove FafnyirTools **Blizzard Bar Art** and **Unit Frame Sources**
because EllesmereUI now includes both capabilities. Remove their modules,
options, defaults, global export/import schema, reset synchronization and runtime
writes. Preserve old saved keys as unknown data during ordinary upgrades and do
not restore either feature without a new request.

## Package revision suffix

2026-09-28: use the standard seven-character abbreviated Git revision in future
package filenames. Build manifests continue to record the full commit revision
and archive SHA-256 digest.

## Retail flyout ownership

2026-09-28: adopt the user-supplied cleaner `FlyoutButtonMatch.lua`. The Retail
fix must not write Blizzard flyout button size, scale, anchors, icon or cooldown
geometry. It may manage EllesmereUI decorative borders and the native background,
and must restore tracked presentation when inactive. Forever remains untouched.

## Inventory search roadmap

2026-09-26: defer the proposed cross-character inventory search interface and
related inventory expansion to v2.0.0. The scope is substantial enough to need
its own development cycle, including asynchronous item-data loading, searchable
and sortable results, scrolling, cache-freshness reporting, and focused in-game
performance testing. Keep v1.1.5 available for a smaller, self-contained change.

## WoW Forever beta line

2026-09-20: prepare a separate Forever beta package without treating it as
runtime verified while Blizzard's SavedVariables bug remains. Preserve Retail
v1.1.3 and share source through runtime gates rather than duplicating the addon.
Use the interface range and EllesmereUI's `FOREVER_SV_BUG` contract; disable
reload-dependent writes while that flag is active.

## Source of truth

2026-08-27: the user authorized consolidating accessible history into a single local project, retaining old chats. Adopt the exact QuestXPFixed v1.1.2 they confirmed works. No addon behavior changes in this consolidation. Future changes must start from this source tree and carry a Git revision.

## Resolved conflicts

| Topic | Decision/evidence |
| --- | --- |
| Four source choices vs three | The Aug 27 **Add ToT and Focus frame sources** task explicitly removed the confusing “Use EllesmereUI Setting” choice for release. Keep only EllesmereUI/Blizzard Default/Hidden; legacy inherited data still resolves without writes. |
| Blanket aura block | Early v1.0.5 required EUI Unit Frames disabled. Aug 27 supersedes that: Blizzard Target skins may coexist with EUI Boss frames, based on effective Target source and session ownership. |
| XP reward API guesses | Several v1.1.0 experimental claims contradicted one another. Final working lineage and current confirmed fix use explicit quest-ID lookup. Do not restore failed quest-selection setter guards. |
| XP colors | Aug 24 explicit user values supersede early approximate purple/blue values and the reference addon's 50% rested alpha: current #5563FF → #C561FF; rested #4F8FFF 100%; quest #FF9600 100%. |
| Persistent Pet meaning | It is a summoned companion/battle pet, not “keep the combat pet frame visible.” Aug 23 user requested per-character choices and credit to Eiya; original WeakAura author attribution still needs verification. |
| Categories | v1.1.1 requested QoL / Unit Frames & Auras / Action Bars / XP & Progression / Bags & Inventory / Layouts / About. Later v1.1.2 explicitly groups Aura Skins under Unit Frames and action controls under Action Bars. Keep current layout during unrelated work; unresolved older category omissions are recorded separately. |
| Version | Keep v1.1.2 for current baseline; no automatic bump for consolidation. Use Git revision/hash to distinguish packages with the same addon version. |
| Claims of release/testing | Old assistant “released” or “passed” statements are historical reports, not proof. Source inventory, actual test outputs and explicit user confirmation are distinguished. No evidence here that this corrected ZIP was published externally. |

## Rejected or deferred experiments

- DataBroker display: user said they would never use it and wanted only useful tools (Aug 9 main conversation). Not in active source; do not re-add.
- Masque/Fafnyir skin port: user discarded the idea on Aug 20 and returned to v1.0.7. The archived Aug 20 v1.0.8 ZIP is an experiment, not the same lineage as the later Aug 23 v1.0.8 bar-art/flyout release. Never select a base by filename/version alone.
- Warband Mail recipient selector/class-color attempts: repeated failures in Aug 22 history; later Quest XP task explicitly excluded failed mail experiments. Existing inventory mail data structures do not imply this selector is implemented.
- Broad inventory/search ambitions and Focus aura styling are not proven shipped features; see OPEN_ITEMS.md.

## Extension rules retained from the user

Do not use EUI's logo or a confusingly similar logo; do not lead the addon name with EllesmereUI; do not join its core addon-list group. Own a distinct Fafnyir Tools options sidebar group instead of inserting into EUI Core/QoL/UI Reskin groups. An internal Fafnyir QoL page is permitted. Preserve the user's Fafnyirs Hoard/category and FafnyirMedia icon references. These are historical project requirements, not a fresh audit of upstream branding policy.

## 2026-09-08 — XP bar border Trial 1

Use one shared EllesmereUI-rendered outer border for the XP bar. Expose the
standard style, size, color and opacity controls under XP & Progression; size
zero disables the border. Do not place separate borders around the current,
rested or completed-quest segments. Keep addon version v1.1.2.

## 2026-09-09 — v1.1.3 global settings transfer

Start v1.1.3 with an allowlisted global-settings export/import format. Exclude
character selections, inventory/economy caches, and device-specific layouts.
Imported text must be parsed as data rather than executed, merge only recognized
fields, preserve unknown local data, create a pre-import backup, require user
confirmation, and reload after application.

The user accepted the stable Safe EllesmereUI Reset Defaults build as the
v1.1.3 release. Keep the withdrawn combined Reset/Disable All implementation
out of this release.


## 2026-08-27 — Full v1.1.2 request

User authorized restoring previously shipped features in this task. Companion
Pet/QoL and history omissions are now resolved. Adopt seven pages: About, QoL,
Unit Frames (source controls, Aura Skins, Resting), Action Bars, XP & Progression,
Bags & Inventory, Layouts. Preserve three source choices and all current behavior.
Retain prior v1.0.9/v1.1.1 credit to raine found in the recovered About source,
in addition to Eiya. Do not treat unimplemented inventory/Focus aura ambitions
as shipped features. No discarded experiments restored.

## 2026-08-27 — FullFixed accepted

User reported “All fixed.” on 2026-08-27 in task 01a04568-9348-7180-8adf-921ebcbdd3b7 after receiving FullFixed. This records user confirmation, not an exhaustive test matrix; client/EUI versions were not supplied.
Adopt source commit 0adfac04691d151a03cfcbf3dfed48b2e533f10f as the known working v1.1.2 baseline. Retain the exact FullFixed ZIP and fingerprint; leave prior artifacts and unfinished wishlist scope unchanged.

## 2026-09-01 — Pet Frame source

The user requested Pet Frame in the selective Unit Frame list. Use EllesmereUI's native `pet` source key with the established EllesmereUI / Blizzard Default / Hidden choices, reload prompt and inherited saved-value behavior. Keep v1.1.2; do not alter the confirmed FullFixed artifact.

## 2026-09-03 — Player aura ownership

The user confirmed that EllesmereUI controls the main Player buff/debuff frames. FafnyirTools Aura Skins must expose and apply Target-only controls and must not style Player aura frames. Preserve old SavedVariables without using them to take ownership back.

2026-10-03 filename correction: use the exact packaged ZIP basename
`Fafnyir_Tools_for_EllesmereUI_(version)_(commit).zip` for GitHub release titles
and CurseForge display names as well as uploaded filenames. The former friendly
display name obscured the correctly named artifact. The repair workflow changes
only existing release metadata; it does not rebuild or replace ZIPs.
