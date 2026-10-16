# Fafnyir Tools Chinese localization

## Final submission

The user confirmed the returned workbook as the final volunteer submission on
2026-10-16. `FafnyirTools_Chinese_Localization_Final.xlsx` contains complete
`zhCN` and `zhTW` text for all 164 rows and is preserved as the translation
source. The locale files use that text without machine edits. Offline
integration is complete; in-game Chinese-client review remains pending.

Use `FafnyirTools_Chinese_Localization_Worksheet.xlsx` to collect Chinese
translations without asking the volunteer to edit Lua source.

## Volunteer workflow

1. Confirm whether the volunteer uses the `zhCN` (Simplified Chinese) or `zhTW`
   (Traditional Chinese) World of Warcraft client.
2. Fill only the matching language column unless the volunteer is fluent in
   both client locales.
3. Prefer official terminology from that WoW client instead of literal or
   machine translation.
4. Preserve brand names and placeholders identified in the worksheet notes.
5. Set completed rows to **Translated**. A second fluent speaker should set them
   to **Reviewed** after checking terminology and in-game context.
6. Return the completed workbook for conversion into locale files and code
   integration.

## Current scope

The workbook contains 164 current interface strings from v1.1.13, including
options, tooltips, dialogs, chat feedback, dropdown choices and inventory
tooltip labels. Historical About-page changelog entries and the English support
diagnostics body are deferred from the first pass because they are lengthy,
high-churn support content.

The addon now includes locale files, English fallback behavior, TOC registration
and automated key coverage. In-game font and layout testing remains required.
