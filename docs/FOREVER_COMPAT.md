# WoW Forever compatibility

Audited 2026-09-20 against WoW Forever beta 1.60.1.69913 (interface 16001)
and EllesmereUI 9.2.1 installed under `_classic_beta_`.

## Static compatibility matrix

| Feature | Forever/EllesmereUI contract found |
| --- | --- |
| Options and sidebar | Shared EllesmereUI module/widgets framework |
| Unit Frame Sources | Source getters/setters and all six existing unit paths |
| Target Aura Skins | Shared AuraKit container API |
| Resting Indicator | Same EUI Player frame; dynamic max-level handling added |
| Right-click Self Cast | Same EAB secure action-button family |
| Blizzard Bar Art | EAB main bar and Blizzard action-bar references; visual test pending |
| Flyout Match | SpellFlyout, EAB buttons and shared border helpers |
| XP and Quest XP | Same EUI XP/Rested frames plus quest and XP APIs |
| Device Layout | Edit Mode manager/layout integration present |
| Inventory | Container, currency-list and tooltip processor APIs present |
| Companion Pet | Current Pet Journal collection and summon APIs present |
| Global transfer | Serializer is portable; import/restore temporarily gated |

Static presence proves an integration path, not in-game rendering or combat
safety. The beta package must remain classified as unverified.

## Temporary upstream blocker

EllesmereUI 9.2.1 documents that Forever beta 1.60.1 does not reliably save
addon SavedVariables. It exposes `EllesmereUI.FOREVER_SV_BUG` and suppresses its
own persisted stores. FafnyirTools therefore blocks Unit Frame source selection,
settings import/restore and Full Reset while that flag is active. The gates
remove themselves automatically when EllesmereUI changes the flag to false.

## Deferred in-game validation

After the persistence defect is fixed, test load/options, all Unit Frame source
choices, XP/Rested/Quest segments, Target auras in combat, action-bar casting,
flyouts and art, Resting/max level, inventory locations and companion pets.
