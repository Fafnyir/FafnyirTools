# Open items — current only

This file lists actionable follow-up work and intentionally deferred product
scope. Confirmed releases, superseded test attempts, retired features and
historical implementation notes belong in `CURRENT_STATE.md`, `DECISIONS.md`
or `CHANGELOG.md`, not here.

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
