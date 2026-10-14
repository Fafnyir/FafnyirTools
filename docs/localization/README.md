# Fafnyir Tools localization volunteer kit

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

This kit does not add localization runtime code or alter addon behavior. Locale
files, English fallback behavior, TOC registration, automated key coverage and
in-game font/layout testing remain implementation work after translations are
returned.
