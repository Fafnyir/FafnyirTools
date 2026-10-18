# Open items — no silent restoration

## v1.1.17 BigWigs Border — test build

- User confirmed build `233c90c` works in game on 2026-10-18. This confirms the
  global Messages-frame discovery reaches and borders the normal message icons.
- Detailed checks of every border style, right-positioned bar icons, fade alpha,
  reload persistence and combat safety remain useful before final release.
- Confirm changing Border Style immediately updates the closed dropdown label
  and selected-list highlight in the post-menu page refresh build.

- Enable the default-off toggle under QoL and start BigWigs test bars. Confirm
  Pixels borders appear on both timer bars and attached spell icons.
- Test normal and emphasized bars, icons on either side, bars without icons,
  UI reload persistence, disabling while bars are visible, and combat safety.
- Test Content Spacing from 0–10 with left- and right-positioned icons; verify
  the icon/indicators remain fixed, the complete bar body moves, zero matches
  native placement, and disabling restores the original geometry.
- Exercise every border returned by the installed EllesmereUI dropdown,
  including behind-layer styles, on normal and emphasized BigWigs bars.
- Trigger normal BigWigs messages with and without icons. Confirm all four
  pooled message icons receive the selected border, fade cleanly with the icon,
  reuse correctly, and follow Content Spacing without shifting text. Emphasized sink icons that
  are embedded directly in text remain outside this test scope.
- Historical test builds `752112e` and `109ee90` failed message-icon discovery;
  `233c90c` supersedes them and is user-confirmed.
- Confirm the style-safe anchor snapshot removes the reported text overlap in
  the BigWigs test-bar style shown in the 2026-10-18 screenshot.
- Confirm BigWigs nameplate icons and its saved profile remain unchanged.
- The six new `zhCN` and `zhTW` strings are AI first-pass translations and
  require Yilang's review for terminology and in-game fit.

## v1.1.16 Leveling Forecast to 90 — in-game test pending

- User screenshot on 2026-10-18 confirms build `b72b994` projects level 81 at
  98.8% plus 604,313 quest XP to **Level 83 — 33.6%**.
- Confirm projections at exact level boundaries, across several levels and at
  level 90. Confirm a changed current-level requirement produces the guarded
  one-level overflow fallback rather than a false multi-level result.
- The same screenshot confirms the two guidance messages render on separate
  rows without overlap.

## v1.1.15 Leveling Forecast — user confirmed

- User reported “Testing passes” on 2026-10-18 and authorized release. Client,
  EllesmereUI version and detailed scenarios were not supplied.
- Exhaustive no-bonus, mixed-bonus, overflow, maximum-level and disabled-XP
  coverage remains separate from that confirmation.
- The supplemental worksheet now contains AI-drafted `zhCN` and `zhTW`
  translations for all twelve new strings, marked **Needs Review**. Obtain
  Yilang's review and corrections before integration or a localization-complete
  release.

## Chinese localization

- Final volunteer translations were received for both `zhCN` and `zhTW` and
  integrated into the v1.1.14 source. Automated locale and regression
  checks pass.
- Verify both Chinese clients in game: font glyph coverage, page navigation,
  options layout, wrapping, dropdown widths, confirmation dialogs, chat
  feedback and inventory tooltips.
- Review the few dynamic English sentences not represented in the worksheet,
  plus About changelog/credits and the support diagnostics body, for a later
  translated pass. Do not invent or machine-translate these strings.
- A second fluent reviewer has not been recorded. Capture any terminology or
  truncation corrections from the volunteer during in-game testing.
- Translator **Yilang** returned six `zhCN` and one `zhTW` wording refinements.
  Record any later client-locale screenshots, truncation reports or corrections.

## 2026-10-14 Retail interface 120105 — in-game check pending

- Confirm the updated package loads without the out-of-date warning on Retail
  12.1.5 and that the Fafnyir Tools options remain available.

## 2026-10-11 resting indicator side — user confirmed

- User reported “Tests fine” for build `23df736` and authorized release.
- Client/EllesmereUI versions and detailed Right/Left, reload, reset and global
  transfer scenarios were not supplied, so this is confirmation rather than an
  exhaustive regression matrix.

## 2026-10-08 name-format retirement — in-game check pending

- Confirm the FafnyirTools First/Last/Whole Name option is absent.
- Confirm EllesmereUI controls the intended name format on main, Party, Raid,
  Nameplate and any other supported frames after reload.
- Confirm no duplicate formatting or surname interference remains on Forever.

## 2026-10-06 XP retirement — in-game check pending

- Verify XP & Progression is absent and the native EUI XP/quest bar works after
  replacing the addon folder and reloading. Existing native settings stay native.
- Previous FafnyirTools XP-specific QA items below are historical, superseded by
  full retirement. Test build 46971a5 used v1.1.9; the released version is v1.1.10.


## 2026-10-05 XP ownership cleanup — user confirmed

- User confirmed appearance and testing with afd5d0c and supplied a screenshot
  showing all three XP segments. Detailed test scenarios/client versions were
  not supplied; exhaustive reload/combat/turn-in coverage remains separate.

## 2026-10-04 XP layering — user confirmed

- User confirmed the new layering looks better after testing `aa4b028` and
  requested a release. Detailed turn-in and level-boundary scenarios remain
  separate manual checks; this is visual confirmation of the new order.


## SharedMedia arrows and Party/Raid role artwork — in-game verification

- User confirmed arrows work on 2026-10-03 with `8def225`; detailed client
  scenarios remain pending. Confirm Tank/DPS/Healer/Combat are absent from
  the corrected arrow selector.
- Confirm both new Unit Frames controls fit the options page on Retail/Forever.
- Enable EUI target arrows, select - Arrow Glow and confirm inward direction,
  native scale/color/position and updates after target changes and pool reuse.
- Switch back to native artwork and test missing registered media fallback.
- User confirmed Party role-icon toggle and subsequently Raid role icons on
  2026-10-03. Tested revision and client/EUI versions were not supplied.
- Detailed scenario coverage remains pending: check Tank/Healer/DPS in both groups,
  native role filters, combat visibility, size and offsets. Disable it and
  verify native artwork returns. Main unit frames and extra frames stay native.
- Test reload persistence, global settings transfer and combat taint in game.

## v1.1.6 diagnostics in-game verification

- Confirm the About-page **Copy Diagnostics** row is aligned and visible.
- Confirm the native copy popup selects/copies the complete report on Retail
  and Forever.
- Review a copied report to confirm the live client, dependency versions and
  enabled feature states match the test installation.

## Forever fog toggle hidden in v1.1.5

- User decision, 2026-09-26: the Forever-only **Volumetric Fog** toggle is
  hidden for v1.1.5.
- Blizzard now overrides the `volumeFog 0` console setting after it is applied;
  players report that fog changes for only a moment and then returns. The
  former control was therefore misleading even though FafnyirTools persisted
  and reapplied its saved choice.
- The implementation is dormant rather than presenting a nonfunctional
  option. Reconsider it only if Blizzard exposes a supported, persistent fog
  setting in a later client build.

## WoW Forever beta validation

- Do not treat the Forever beta package as fully testable until Blizzard fixes
  SavedVariables persistence and EllesmereUI removes `FOREVER_SV_BUG`.
- Then verify sidebar/options registration, Unit Frame sources, settings
  import/reset, Target auras, XP/Rested/Quest overlays, Resting, action-bar
  behavior, bags/bank/currencies/tooltips and companion summoning in game.
- The package must remain separate from the Retail installation and release.

## Resolved in consolidated v1.1.2

Persistent Companion Pet, QoL, companion defaults/events/TOC/options, prior
release history and companion credits are restored. The prior source credited
raine for the original WeakAura; that existing attribution is retained (not a
new independent author verification). Eiya credit is retained as well.

Options are consolidated to seven pages with Resting under Unit Frames,
XP & Progression and Layouts. This preserves later Aura/source and Action Bars
grouping. Legacy Quest XP setting names now migrate without overwriting newer
saved values. These changes are offline-tested; the user confirmed “All fixed.” on 2026-08-27. See CURRENT_STATE.md for the exact build and limits of this report.

## 3. Broader inventory functionality

Historical request covered searching all characters, bags, banks, mail, auctions, warband/guild storage, gold/currencies. Current code scans bags, personal bank and currency list and aggregates cached locations; dedicated mail/auction/warband/guild scanners and a search UI are not present. Existing data tables/tooltip labels are not implementation. Keep as a future scope decision; do not advertise complete live tracking.

Roadmap decision, 2026-09-26: full inventory search is deferred to v2.0.0.
Start with reliable cached character bags and personal banks, asynchronous item
metadata, result sorting, and cache-age reporting. Mail, auction, Warband, and
guild scanners remain separate API-validation work and are not automatically
included merely because the v2.0.0 search project begins.

## 4. Focus aura styling

Focus source control exists. Custom Focus aura containers do not. Treat as a separate feature request if desired.

## 5. Release assurance / backup

Offline mocks do not verify real EUI render layers, combat taint, or every retail API behavior. Follow TESTING.md for releases. No upstream/remote repository or off-machine backup has been configured; local Git and the supplied snapshot only protect against local editing mistakes. Publishing/backing up to a remote requires a separate destination/authorization.

## 6. Historical coverage limits

The main chat was recovered as 204 turns spanning Aug 5–27 from cached paginated reads, including a terminal oldest page and refreshed newest page. Identified local development task texts were consolidated; mixed-topic Website/WoW material is selectively indexed. Binary attachments are not a complete archive, and unrelated chats were not exhaustively read for incidental mentions. No claim is made that inaccessible/deleted/other-account chats have been merged. Use source IDs in HISTORY.md to revisit any missing context.

## 7. Reset / Disable All redesign

The first v1.1.3 implementation was withdrawn after repeated disconnects in the
test build. Revisit only after the rollback build is stable. Avoid synchronizing
all source ownership and refreshing every feature inside one live options reset
callback; stage changes for the next login instead.
