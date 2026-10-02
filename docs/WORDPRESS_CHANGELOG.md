# Fafnyir Tools for EllesmereUI — Full Changelog

Fafnyir Tools is a collection of focused enhancements for EllesmereUI. It adds quality-of-life controls, unit-frame options, XP improvements, action-bar fixes, inventory tracking, layout switching, and WoW Forever compatibility while leaving EllesmereUI as the primary interface suite.

**Current version:** v1.1.5

**Required addons:** EllesmereUI and FafnyirMedia

## v1.1.5 — Compatibility Cleanup

- Added FafnyirMedia as a required dependency alongside EllesmereUI.
- Removed Party and Raid handling from FafnyirTools name display modes after EllesmereUI added native controls for those frames. Main unit-frame name modes remain available.
- Removed the duplicate XP Bar border controls after EllesmereUI added native support. Existing legacy settings remain untouched for compatibility.
- Removed the duplicate three-zone XP text override after EllesmereUI added native support. Existing legacy settings remain untouched for compatibility.
- Fixed XP layering so current XP appears on top, Rested XP appears second, and completed Quest XP remains behind both.
- Limited Flyout Fix to Retail. On WoW Forever the option is hidden and EllesmereUI handles flyouts natively.
- Removed unnecessary action-slot and binding event refreshes from Right-Click Self Cast, preventing repeated full-button scans during high-frequency action or modifier-state updates.
- Hid the WoW Forever Volumetric Fog option after Blizzard made the underlying `volumeFog` setting non-persistent.
- Stopped applying or repeatedly reapplying the unsupported fog console setting.
- Preserved the legacy saved preference and export structure so existing profiles remain compatible.
- Kept this release intentionally focused on cleanup and regression prevention rather than adding an overlapping feature already supplied by EllesmereUI.

## v1.1.4 — WoW Forever Compatibility and Interface Improvements

### WoW Forever support

- Added guarded support for WoW Forever interface 16001 while retaining Retail compatibility.
- Added reliable Forever client detection using the interface version range.
- Updated maximum-level detection to use client APIs instead of a Retail-specific fixed level.
- Updated companion-pet enumeration for the current Pet Journal API while retaining the legacy fallback.
- Added safeguards for reload-dependent settings when the early Forever SavedVariables defect was present.
- Updated reload confirmations to use EllesmereUI's secure reload path, preventing protected-action errors.

### XP and progression

- Added an optional three-zone XP text layout with Level on the left, current XP, maximum XP, and percentage in the center, and rested XP percentage on the right.
- Kept EllesmereUI's font styling and live XP/rested updates.
- Restored EllesmereUI's native centered XP text when the custom layout is disabled.

### Unit frames

- Added First Name, Last Name, and Whole Name display modes for surname-bearing WoW Forever characters.
- Applied name modes to EllesmereUI main, Party, and Raid frames while leaving Nameplates, NPC names, configured nicknames, secret names, and Retail unchanged.
- Added a Blizzard-style colored Focus header option using EllesmereUI's native Focus setting.
- Kept the Focus option independent from the Target reaction-header setting.

### Action bars

- Unified the central Blizzard action-bar background and both side griffons under the existing Blizzard Bar Art toggle.
- Prevented Blizzard's hidden end-cap editing overlay, including “Click To Edit,” from appearing.
- Made Blizzard Bar Art recover after paging, specialization changes, shapeshifts, vehicle and override states, zone transitions, combat transitions, and Edit Mode updates.
- Added an Art Scale adjustment from 1.00 to 1.10 for systems where UI scaling changes the required fit.
- Excluded Art Scale from global exports because it is a device-specific visual calibration.

### Inventory tracking

- Added a confirmed Reset All Characters action for character-keyed inventory data.
- Added individual cached-character removal while protecting the currently logged-in character.
- Reset character, mail, and auction caches while preserving Warband and guild caches.
- Rescanned the current character after a reset when inventory tracking was enabled.

## v1.1.3 — Global Settings Transfer

- Added versioned global settings export and import.
- Added strict validation so imported text is parsed as data and never executed as Lua.
- Imported only recognized settings while preserving unknown local fields for forward compatibility.
- Created a rollback snapshot before applying an import.
- Added confirmation and a secure UI reload after importing or restoring a backup.
- Moved Global Settings to the top of the About page.
- Synchronized imported Unit Frame source choices with EllesmereUI before reload so changes apply after one reload instead of two.
- Excluded per-character companion selections, inventory and economy caches, and device-specific Edit Mode layouts from global exports.
- Restored EllesmereUI as the explicit reset default for Player, Target, Target of Target, Focus, Boss, and Pet frames.

## v1.1.2 — Selective Unit Frames, Target Auras, Quest XP, and XP Borders

### Unit-frame sources

- Added independent source controls for Player, Target, Target of Target, Focus, Boss, and Pet frames.
- Added three choices for each supported frame: EllesmereUI, Blizzard Default, or Hidden.
- Used EllesmereUI's native source API and retained the required reload workflow.
- Preserved legacy inherited choices without silently rewriting existing settings.

### Target Aura Skins

- Limited FafnyirTools Aura Skins to Blizzard Target auras; EllesmereUI remains responsible for the main Player buff and debuff frames.
- Allowed Blizzard Target aura styling while other frame types continue using EllesmereUI.
- Added Target aura size, zoom, duration text, text size, filters, borders, and related controls.
- Wrapped Target buffs and debuffs after six icons per row.
- Preserved session ownership until reload to avoid mixed Blizzard/EllesmereUI aura states.

### Quest XP and XP bar

- Restored the completed-quest XP overlay as an orange segment extending forward from current XP.
- Counted XP from completed quests currently ready to turn in.
- Clipped the overlay at the current level boundary.
- Hid the overlay at maximum level, when no completed quest XP is available, or when disabled.
- Added independent Quest XP enable and color controls.
- Set the Quest XP default to `#FF9600` at 100% opacity.
- Preserved the current XP gradient defaults of `#5563FF` to `#C561FF`.
- Preserved the Rested XP default of `#4F8FFF` at 100% opacity.
- Migrated older Quest XP preferences only when the newer settings were absent.
- Added EllesmereUI-style border texture, size, color, and opacity controls for one shared XP-bar border.
- Corrected border layering and offsets so the Blizzard-style border aligns around the complete bar.

### Restored and reorganized features

- Restored Permanent Companion Pet with per-character choices.
- Restored Blizzard Bar Art and Flyout Fix controls.
- Organized the addon into About, QoL, Unit Frames, Action Bars, XP & Progression, Bags & Inventory, and Layouts.
- Moved Aura Skins and Resting under Unit Frames.
- Grouped the action-bar enhancements under Action Bars.

## v1.1.1 — Options Organization

- Reorganized settings into dedicated Fafnyir Tools pages.
- Moved Permanent Companion Pet into the QoL section.
- Retained the Quest XP and XP-color work introduced in v1.1.0.

## v1.1.0 — Completed Quest XP

- Added a configurable overlay showing XP available from completed quests ready to turn in.
- Added login, world-entry, quest-log, XP, level, exhaustion, and quest-data refresh handling.
- Added automatic hiding at maximum level or when completed quest XP is zero.
- Updated the current XP gradient default to `#5563FF` through `#C561FF`.
- Updated the Rested XP default to `#4F8FFF` at full opacity.
- Added the Quest XP default color `#FF9600` at full opacity.
- Preserved saved custom colors and enable choices.

## v1.0.9 — Permanent Companion Pet

- Added persistent companion-pet summoning.
- Added Random Favorite and Specific Pet modes.
- Stored the selected mode and pet separately for each character.
- Avoided summoning while mounted, stealthed, in combat, on a taxi, or in disabled PvP instances.
- Added configurable PvP safety behavior.
- Credited Eiya for the feature idea and raine for the original Permanent Companion Pet WeakAura.

## v1.0.8 — Blizzard Bar Art and Flyout Fix

- Added optional Blizzard decorative artwork for EllesmereUI Bar 1.
- Added automatic artwork scaling and alignment for custom button sizes.
- Added Flyout Fix so spell-flyout buttons follow their parent action bar's size and border styling.
- Added persistent toggles for Blizzard Bar Art and Flyout Fix.

## v1.0.7 — Target Aura Improvements

- Rebuilt Blizzard Target aura handling for the current AuraKit system.
- Added independent Target aura sizing.
- Added Target buff filters for All, Stealable, Big Defensive, and Dispellable auras where supported.
- Added Target debuff filters including All, Own Only, and Important.
- Automatically hid the relevant Blizzard Target and Focus status textures.

## v1.0.6 — Device Layouts

- Added automatic Blizzard Edit Mode layout switching.
- Added a per-device default layout.
- Added optional per-specialization layout overrides.
- Added automatic layout switching after specialization changes.
- Added a concise loaded-layout chat message.

## v1.0.5 — Aura Skins and Right-Click Self Cast

- Updated Right-Click Self Cast for EllesmereUI action buttons.
- Added the original Aura Skins module for Blizzard aura frames.
- Added aura size, border, zoom, duration, and text controls.
- Added a reload confirmation for aura ownership changes.
- Removed the redundant Fafnyir Tools heading from inventory tooltips.

## v1.0.4 — Inventory Tooltip Polish

- Added class colors to character names in item-location tooltips.
- Updated the project credit to “Envisioned by Fafnyir.”

## v1.0.3 — About Page and Inventory Foundation

- Added the About page, version information, changelog, credits, and support link.
- Added bag and personal-bank item caching.
- Added account gold totals and currency caching.
- Added item-location counts to tooltips.

## v1.0.2 — XP Gradient Fixes

- Fixed XP-bar gradient flickering.
- Fixed the Rested XP gradient reverting to white.
- Updated the project description.

## v1.0.1 — XP and Rested Gradients

- Added configurable XP and Rested XP gradients.
- Added gradient direction controls.
- Added color pickers.

## v1.0.0 — Initial Release

- Added the Resting indicator for the EllesmereUI Player frame.
- Added Right-Click Self Cast for supported EllesmereUI action buttons.
- Added native EllesmereUI integration and a dedicated Fafnyir Tools settings area.

## Credits

- Envisioned by Fafnyir.
- Special thanks to Ellesmere, creator of EllesmereUI.
- Permanent Companion Pet idea by Eiya: `twitch.tv/eiya`.
- Original Permanent Companion Pet WeakAura by raine: `wago.io/3It1XU72A`.

## Compatibility Notes

- EllesmereUI and FafnyirMedia are required.
- Existing saved settings are preserved during upgrades; missing settings receive defaults without overwriting established choices.
- Device-specific Art Scale and Edit Mode layout selections are intentionally excluded from global settings transfers.
- Dedicated cross-character inventory search and broader mail, auction, Warband, and guild-bank scanning are planned separately and are not part of v1.1.5.
