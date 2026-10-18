# Fafnyir Tools Chinese localization

## Final submission

The user confirmed the returned workbook as the final volunteer submission on
2026-10-16. `FafnyirTools_Chinese_Localization_Final.xlsx` contains complete
`zhCN` and `zhTW` text for all 164 rows and is preserved as the translation
source. The locale files use that text without machine edits. Offline
integration is complete; in-game Chinese-client review remains pending.
The translator is **Yilang**, credited in the addon's About page.
Yilang returned six Simplified Chinese and one Traditional Chinese wording
refinements on 2026-10-16; those Lua files are the current authoritative text.

Use `FafnyirTools_Chinese_Localization_Worksheet.xlsx` to collect Chinese
translations without asking the volunteer to edit Lua source.

## v1.1.15 Leveling Forecast supplement

`FafnyirTools_Leveling_Forecast_Chinese_Localization_Worksheet.xlsx` contains
the twelve English fallback strings added for the Leveling Forecast after the
v1.1.14 translation pass. It preserves the same zhCN/zhTW, translator-note,
reviewer and status workflow as the original workbook. The two formatted rows
identify their required `%d` and `%s` placeholders explicitly. Integrate the
returned translations only after checking placeholder parity and Lua syntax.
The workbook includes an AI-drafted first pass for both locales, with every row
marked **Needs Review** for Yilang to verify against official WoW terminology,
natural phrasing and in-game layout.

For future localization additions, provide a complete AI-drafted first pass in
both Chinese columns when practical, preserve all placeholders, and mark those
entries **Needs Review**. A fluent volunteer remains the authority for approval;
do not integrate draft text as final merely because the worksheet is complete.

## Volunteer workflow

1. Confirm whether the volunteer uses the `zhCN` (Simplified Chinese) or `zhTW`
   (Traditional Chinese) World of Warcraft client.
2. Review the matching language column; review both only when fluent in both
   client locales. Replace draft wording rather than preserving it out of
   deference to the first pass.
3. Prefer official terminology from that WoW client instead of literal or
   machine translation.
4. Preserve brand names and placeholders identified in the worksheet notes.
5. AI-drafted rows begin as **Needs Review**. Set completed rows to
   **Translated** after translator approval. A second fluent speaker should set
   them to **Reviewed** after checking terminology and in-game context.
6. Return the completed workbook for conversion into locale files and code
   integration.

## Current scope

The workbook contains 164 interface strings introduced for v1.1.14, including
options, tooltips, dialogs, chat feedback, dropdown choices and inventory
tooltip labels. Historical About-page changelog entries and the English support
diagnostics body are deferred from the first pass because they are lengthy,
high-churn support content.

The addon now includes locale files, English fallback behavior, TOC registration
and automated key coverage. In-game font and layout testing remains required.
