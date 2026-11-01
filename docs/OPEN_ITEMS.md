# Open items — current only

This file lists actionable follow-up work and intentionally deferred product
scope. Confirmed releases, superseded test attempts, retired features and
historical implementation notes belong in `CURRENT_STATE.md`, `DECISIONS.md`
or `CHANGELOG.md`, not here.

## v2.0.0 standalone-capability test

- Retail standalone XP presentation is confirmed by the user in build
  `f18ff22`: corrected colors and end bounds, explicit rested XP, Quest/rested
  ordering and the flicker correction all pass in game. Forever testing is not
  available before launch. At launch, repeat the XP matrix there—both gradient
  orientations, rested present/absent, Quest overlap, level boundaries,
  maximum/XP-disabled states, tracked-bar competition, Edit Mode, persistence,
  reset and live color changes—and confirm the Camelot track mask matches its
  alternate art. Re-enable EllesmereUI and confirm ownership still transfers.

- Test standalone window resizing at minimum, default and maximum dimensions;
  verify the grip, scroll area, three-column rows, reload persistence, Reset
  Window Size, UI scaling and `zhCN`/`zhTW` wrapping. Confirm EllesmereUI's
  integrated options window is unchanged.
- Confirm the compact 44-unit label rows and vertically centered Leveling
  Forecast values at several UI scales and at minimum window width, including
  wrapping of the guidance sentence in Chinese locales.

- Test the integrated FPS Display in standalone Retail and Forever: enable,
  drag persistence, world-latency toggle, font-size range, reset, `/fpsdisplay`,
  UI scale changes and monitor/resolution changes.
- Test Nicer Damage in standalone Retail and Forever: enable and disable with
  both Reload Now and Later, confirm the bundled font affects Blizzard floating
  damage text, and check that no other combat-text addon is overriding it.
- Confirm Target and Focus reaction/status strips remain hidden through target
  changes in standalone mode without duplicate hooks.
- Test Hide Default Tooltip Health Bar on player, friendly, hostile, NPC and
  dead-unit tooltips in standalone Retail and Forever. Confirm live off/on
  changes, reload persistence, no one-frame health-strip flash, and no taint.
- Test Mouseover Action Bars in standalone Retail and Forever across all eight
  primary/multi bars plus Pet and Stance bars. Check zero and partial opacity,
  adjacent-button movement, Edit Mode changes, paging, vehicles, combat,
  individual bar selections, disable restoration, Reload Now/Later behavior,
  reload persistence, and hidden-bar mouse hit testing. Repeat hover and
  restoration checks for the Micro Menu and Bag Bar, including each child
  button and the Forever fallback frame names.
- Test the standalone minimap button on Retail and Forever: click toggling,
  tooltip, drag at every quadrant, persistence after reload, UI scale/minimap
  size changes, reset behavior, combat, and coexistence with button collectors.

- Test without EllesmereUI on both Retail and Forever: `/faftools`, every page,
  toggles, click-to-cycle selectors, text input, popups, Refresh and scrolling.
- Confirm the compact skinned window, Fafnyir palette, pixel borders and
  mixed `- THE BOLD FONT` headings/controls and `- THE FONT` body copy
  render correctly at several UI scales and resolutions; confirm the restored
  two-color Fafnyir Tools title remains visible.
- Confirm slider values remain centered beside Horizontal/Vertical Resting,
  FPS font size, action-bar opacity and other sliders at all window widths.
- QoL's active purple label/underline and the complete Native Resting control
  row are confirmed in game in build `30e80ff` (2026-10-31).
- Recheck `General.log` for new Fafnyir Tools Lua errors after hovering controls;
  the obsolete tooltip call has been corrected.
- Confirm enabling Native Resting Controls shows Reload Now/Later and that the
  setting is active after accepting the reload; Later should preserve the saved
  enabled value.
- Toggle-label alignment is confirmed fixed in build `16dd10c`; retain the
  22-pixel vertically centered label and six-pixel checkbox gap.
- The user confirmed the EllesmereUI-installed v2 test is fully functional with
  no errors on 2026-10-31. Exact client and scenario coverage were not supplied;
  broader Retail/Forever matrix testing remains optional follow-up coverage.
- Exercise Blizzard native action bars before, during and after combat; confirm
  paging and disabling right-click self-cast restore expected behavior.
- Confirm installing/removing optional FafnyirMedia produces no load error.
- Have Yilang review the twenty-nine new standalone-mode strings and check native
  window wrapping on `zhCN` and `zhTW` clients.
- Test Native Resting controls on the Blizzard Player frame in Retail and
  Forever: offsets, resting-state transitions, effective max level, reset,
  disabling, reload persistence and combat/vehicle transitions. The four new
  Chinese strings are first-pass translations pending Yilang's review.
  Offset application is confirmed in game; the three-column +/-25 sliders,
  visible Reset button, moving thumbs, live numeric feedback and double-click
  reset await confirmation.
- Release automation now derives the GitHub title and CurseForge display name
  from the packaged artifact, preserving the v2 standalone identity without
  changing historical v1 filenames.

## v1.1.20 Leveling Forecast refresh test

- The user reported that build `2184a77` passes in-game testing on 2026-10-31.
  Exact client and scenario coverage were not supplied, so a Retail/Forever
  matrix and repeated-click/page-scroll stress pass remain optional follow-up
  coverage rather than release blockers.
- Have Yilang review the new `zhCN` and `zhTW` Refresh wording and verify button
  width on native Chinese clients.

## v1.1.19 client-specific verification

The user reported that test build `8247f07` ran without errors and authorized
the v1.1.19 release. The exact client coverage was not supplied, so these are
useful follow-up checks rather than release blockers:

- Retail: confirm Fafnyir Tools has no Flyout Fix or Bags & Inventory page,
  EllesmereUI owns both surfaces, and the Fafnyir companion controls remain.
- Forever: confirm Fafnyir Tools has no companion-pet controls, EllesmereUI
  Forever Essentials owns pet persistence, and Fafnyir Bags & Inventory remains.
- On both clients, confirm an ordinary upgrade leaves dormant legacy flyout,
  inventory and companion SavedVariables untouched.
- Confirm CurseForge file `9376718` is publicly available after moderation.
- Verify or manually update the independently hosted Wago release; the current
  release workflow publishes only GitHub and CurseForge.

## Runtime coverage worth retaining

These features have passed offline validation and received the user
confirmations recorded in `CURRENT_STATE.md`. The cases below are additional
coverage, not evidence of a known defect.

### BigWigs borders

- Exercise normal and emphasized timer bars, icons on both sides, bars without
  icons, message-icon fading and pooled reuse.
- Check every currently offered EllesmereUI border style, including styles
  drawn behind content.
- Confirm spacing zero and disabling restore native geometry, BigWigs
  nameplate icons stay untouched, and no saved BigWigs profile value changes.
- Repeat during combat to check for protected-action or taint errors.

### Leveling Forecast

- Verify exact level boundaries, projections spanning several levels and the
  level-90 cap.
- If Blizzard changes the XP curve, confirm the guarded one-level overflow
  fallback appears instead of a false multi-level estimate.

### Shared artwork and diagnostics

- Check SharedMedia target arrows through target changes and nameplate pool
  reuse, including native restoration when disabled or media is unavailable.
- Check Tank, Healer and DPS replacement artwork in both Party and Raid while
  preserving EllesmereUI visibility, size, position and combat rules.
- Confirm the About-page diagnostics popup copies the complete privacy-safe
  report on both Retail and Forever and reports only active flavor features.

### Chinese localization

- On native `zhCN` and `zhTW` clients, check glyph coverage, wrapping, control
  widths, dropdowns, confirmation dialogs and current feature terminology.
- Keep Yilang's reviewed strings authoritative. Any new strings should receive
  a first-pass translation marked **Needs Review** until a fluent reviewer
  verifies terminology and in-game fit.
- About history, credits, diagnostics and dynamic English sentences remain a
  possible future translation pass.

## Explicitly deferred product work

### Cross-character inventory search — v2.0.0

The broader inventory project remains deferred to v2.0.0. Start with reliable
cached character bags and personal banks, asynchronous item metadata, sorting
and cache-age reporting. Mail, auction, Warband and guild scanners require
separate API validation and are not implied by the initial search scope.

Retail now delegates offline inventory to EllesmereUI Bags. Re-evaluate the
need for a separate Fafnyir search interface against EllesmereUI's current
capabilities before starting v2.0.0.

### Focus aura styling

Custom Focus aura containers are not implemented. The existing Focus reaction
header is a separate supported feature. Add Focus aura styling only after a new
explicit request and a fresh comparison with EllesmereUI.

### Volumetric fog

The Forever fog control remains dormant because Blizzard restores `volumeFog`
after it is changed. Reconsider it only if Blizzard exposes a supported,
persistent setting.

### Reset / Disable All redesign

The original combined reset/disable experiment was withdrawn after disconnect
reports. Do not restore it without a new request. Any redesign should stage
cross-addon ownership changes for the next login instead of refreshing every
feature synchronously from one callback.
