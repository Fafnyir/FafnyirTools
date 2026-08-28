# Verification and release checklist

## Offline

Use `python tools/check.py` with Lupa 2.8 installed. Tests run under Lua 5.1 with mocked WoW/EUI APIs. They verify behavior against the mock contract, not compatibility with every future client.

- test_xp.py: syntax of all active Lua; TOC/version; positive completed rewards, exclusions/deduplication; start/clipping/resizing; max level/zero/disabled XP; toggle and colors; saved settings; gradients; login and registered quest events; actual options registration/build for XP; late bar retry.
- test_aura_sources_options.py: target source availability, native aura hiding/restoration, disabled/deferred guards, session-stable ownership, delayed namespace, six-icon widths at multiple sizes; combined options offsets and search terms; all 15 frame-source selections; inherited/unset values without writes; invalid choices; missing API; reload callbacks.
- check.py: expected modules/features/default sections; TOC uniqueness and completeness; matching About/TOC version; artifact fingerprints; syntax; optional byte-for-byte baseline comparison.

Tests are inherited from the two relevant build tasks and made independent of their old source folders. Exact assertions intentionally protect current behavior; authorized version/category changes need corresponding updates. Do not remove a test merely to conceal a regression.

## In game (record date, client/EUI version, Git revision and result)

1. Back up SavedVariables; upgrade without deleting them. Confirm custom colors, alpha, toggles and frame choices survive reload/relog.
2. Below max level, complete two XP-bearing quests without turn-in. Compare reward sum and orange segment against current XP; turn in/abandon quests and verify updates. Test zero, incomplete-only, capped-at-level and no-rested cases.
3. Toggle Quest XP independently of gradient. Check orange above rested range, current XP/text unobscured, EUI visibility and bar resize/movement.
4. Max-level character: no Quest XP segment. Test disabled XP if available.
5. Set Player/Target/ToT/Focus to Blizzard and Boss to EUI, reload, verify actual boss encounter and no duplicate frames. Exercise EUI/Hidden choices. Confirm ToT parent dependency.
6. Change source, choose Later: current aura ownership must stay stable until reload. Reload and check new owner. Confirm inherited legacy settings resolve without changing EUI choices.
7. Target auras: 6/7/12/13 buffs and debuffs, filters, sizes, no overlap or native duplicate rows; test combat and target switching. Focus source selection is not Focus aura skinning.
8. Action art follows Bar 1 movement/size and toggles; flyout shape/border matches owner; right-click self cast and normal left-click work.
9. Resting animation/size/offsets; layout switching/login message/spec change; inventory scans/tooltips/class colors and toggles.
10. Open every options page at the user's UI scale and confirm labels, scroll ranges and no duplicate/missing controls.

Companion Pet is restored and offline-tested. The user confirmed the combined FullFixed build with “All fixed.” on 2026-08-27; this does not establish that every checklist case was exercised. Broader storage scanners are not present. Record actual user reports separately from offline passes in CURRENT_STATE.md.

## Packaging

Only package from a clean committed source tree using tools/package.py. Review docs/OPEN_ITEMS.md before calling a build a release. The packager reruns checks and checks ZIP contents; it does not install, publish, or certify in-game behavior.

## Consolidation validation evidence (2026-08-27)

All offline suites passed against the exact baseline. Temporary-copy negative probes confirmed that checks fail when Quest XP calculation is disabled, Focus source application is removed, or the Flyout module is dropped from the TOC. No production source was changed for these probes.


## Companion restoration coverage

New test_companion.py covers per-character and legacy setting preservation,
random/specific selection, owned/favorite filtering, resets, all summon safety
conditions, throttle/coalescing, core login/event dispatch, missing API handling,
seven real feature pages, legacy Quest XP preference migration, slash navigation
and measured About text wrapping. Validate all these in game after upgrade,
especially mount/dismount, combat exit, per-character pet selection and reload.
