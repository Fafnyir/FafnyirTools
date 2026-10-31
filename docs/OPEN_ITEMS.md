# Open items — current only

This file lists actionable follow-up work and intentionally deferred product
scope. Confirmed releases, superseded test attempts, retired features and
historical implementation notes belong in `CURRENT_STATE.md`, `DECISIONS.md`
or `CHANGELOG.md`, not here.

## v2.0.0 standalone-capability test

- Test without EllesmereUI on both Retail and Forever: `/faftools`, every page,
  toggles, click-to-cycle selectors, text input, popups, Refresh and scrolling.
- Confirm the compact skinned window, Fafnyir palette, pixel borders and
  `- THE FONT` render correctly at several UI scales and resolutions.
- Confirm the clicked-button-owned underline follows QoL and every other
  standalone tab after explicitly anchoring each accent to its owning button.
- Toggle-label alignment is confirmed fixed in build `16dd10c`; retain the
  22-pixel vertically centered label and six-pixel checkbox gap.
- The user confirmed the EllesmereUI-installed v2 test is fully functional with
  no errors on 2026-10-31. Exact client and scenario coverage were not supplied;
  broader Retail/Forever matrix testing remains optional follow-up coverage.
- Exercise Blizzard native action bars before, during and after combat; confirm
  paging and disabling right-click self-cast restore expected behavior.
- Confirm installing/removing optional FafnyirMedia produces no load error.
- Have Yilang review the five new standalone-mode strings and check native
  window wrapping on `zhCN` and `zhTW` clients.
- Test Native Resting controls on the Blizzard Player frame in Retail and
  Forever: offsets, resting-state transitions, effective max level, reset,
  disabling, reload persistence and combat/vehicle transitions. The four new
  Chinese strings are first-pass translations pending Yilang's review.
  Offset application is confirmed in game; the three-column +/-25 sliders,
  visible Reset button, moving thumbs, live numeric feedback and double-click
  reset await confirmation.
- Release automation still uses the v1.x `for_EllesmereUI` artifact identity;
  update it only if the standalone design is accepted for release.

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
