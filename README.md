# Fafnyir Tools

Standalone quality-of-life tools for World of Warcraft Retail and WoW Forever,
with optional enhancements for EllesmereUI and Naowh Forever.

**Current release:** v2.0.6

[Download the latest GitHub release](https://github.com/Fafnyir/FafnyirTools/releases/latest) ·
[CurseForge](https://www.curseforge.com/wow/addons/fafnyir-tools) ·
[Wago](https://addons.wago.io/addons/fafnyirtools) ·
[Support development](https://www.patreon.com/cw/fafnyir)

## What it does

Fafnyir Tools can run as a standalone addon. When supported companion addons
are installed, their integration-specific enhancements appear automatically.
Existing settings remain saved if an integration is temporarily unavailable.

### Standalone tools

- Native Fafnyir Tools settings window with a minimap launcher and optional
  Fafnyirs Button Collector.
- Completed-quest Leveling Forecast with projected level progress. WoW Forever
  includes the live Cozy Sleeping Bag quest-XP bonus.
- Blizzard XP-bar gradients with Current XP, Rested XP and completed Quest XP
  layering when another addon is not managing the bar.
- Optional mouseover fading for Blizzard action bars, Pet Bar, Stance Bar,
  Micro Menu and Bag Bar.
- Right-click self-casting on supported action bars.
- Movable native resting indicator with optional max-level hiding.
- Optional FPS and world-latency display.
- Optional Nicer Damage font and default-tooltip health-bar suppression.
- Retail and Forever Permanent Companion Pet controls with per-character pet
  choices and safety guards.
- Forever inventory fallback with cached character totals and item-location
  tooltips when EllesmereUI Bags or Naowh Alt Item Counts is not active.
- Per-installation Edit Mode device layouts and global settings transfer.

### EllesmereUI enhancements

- Resting indicator controls for EllesmereUI unit frames.
- Blizzard Target aura styling and six-icon aura rows.
- Blizzard-style Focus reaction header.
- SharedMedia target-arrow and Party/Raid role artwork integration.
- Selectable EllesmereUI borders for Damage Meter Icon History and BigWigs
  bars, spell icons and message icons.
- Optional click-only EllesmereUI Center Reticle.

### Naowh Forever integration — v2.0.5

- Apply the selected EllesmereUI border to Naowh Forever Food & Drink,
  Consumable, Gear Set, Trinket, Blessings, Sleeping Bag and Fishing Pole
  Reminder icons.
- Pixels is the default style with a 24-pixel edge; other styles retain their
  EllesmereUI defaults.
- Optional Clickable Fishing Pole Reminder securely casts the highest Fishing
  rank your character knows without requiring a keybind or One-Key Fishing.
- Ctrl-click dismissal remains available. The reminder tooltip is suppressed
  while clickable mode is enabled.
- Naowh settings and native secure actions are not modified.

## Optional dependencies

None are required for standalone operation.

- **EllesmereUI** enables the established unit-frame, border, artwork and
  reticle integrations.
- **FafnyirMedia** supplies optional shared fonts and artwork.
- **Naowh Forever** enables the Forever-specific icon-border integration;
  EllesmereUI is also required to supply the selected border styles.

Fafnyir Tools detects overlapping features and yields ownership where
appropriate instead of deleting dormant settings or cached data.

## Installation

1. Download the latest release ZIP.
2. Extract it into your World of Warcraft `Interface/AddOns` directory.
3. Confirm the resulting folder is named `FafnyirTools`.
4. Enable the addon and reload the interface.

Open the settings with `/faftools` or the standalone minimap button. When
EllesmereUI is installed, Fafnyir Tools appears in its options sidebar.

Do not delete `FafnyirToolsDB` when upgrading; releases preserve existing
settings and unknown legacy data.

## Localization

English is the fallback language. Complete Simplified Chinese (`zhCN`) and
Traditional Chinese (`zhTW`) interface files are included.

Special thanks to **Yilang** for volunteering Chinese translations and ongoing
language review. Strings added after the latest reviewed worksheet are marked
in the project records as first-pass translations pending review.

## Support diagnostics

The About page can copy a privacy-safe diagnostics report for support requests.
It includes addon/client versions and active feature states, but excludes
character names, account details and raw SavedVariables.

## Development

The canonical addon source is [`src/FafnyirTools`](src/FafnyirTools). Historical
ZIPs and archived conversations are reference material and are not build input.

Run the offline validation suite with:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python tools/check.py
```

Create a verified local package from a clean committed tree with:

```sh
.venv/bin/python tools/package.py
```

Packaging does not replace in-game testing. See
[`docs/TESTING.md`](docs/TESTING.md) for the manual test matrix and
[`docs/FEATURES.md`](docs/FEATURES.md) for current ownership and feature
contracts.

## License and bundled assets

Bundled third-party asset notices are recorded in
[`src/FafnyirTools/Media/THIRD_PARTY.txt`](src/FafnyirTools/Media/THIRD_PARTY.txt).
