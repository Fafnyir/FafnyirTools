# Reconciled decisions

## GitHub release automation

2026-10-03: releases may be built through the private repository's manually
triggered GitHub Actions workflow. The operator must confirm the TOC version and
choose Draft, Prerelease, or Final; Draft is the safe default. The workflow
reuses `tools/package.py`, creates `release/<version>`, uploads the ZIP and build
manifest, and refuses to overwrite an existing release tag. Offline automation
does not replace in-game validation.

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
