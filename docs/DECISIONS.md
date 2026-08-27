# Reconciled decisions

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
