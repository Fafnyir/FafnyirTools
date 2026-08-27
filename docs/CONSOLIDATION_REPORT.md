# Consolidation verification — 2026-08-27

- Authoritative folder: /Users/fpatten/Documents/Codex/FafnyirTools.
- Initial Git baseline: de9b994c42124ff7f1e18c3b2bbcb1d347d13e89.
- Active addon source: all 19 files equal the user-confirmed v1.1.2 QuestXPFixed ZIP.
- Recovered main history: 204 turns from oldest through newest available pages.
- Nine identified local task text snapshots plus selected WoW flyout excerpts.
- Twenty earlier ZIPs fingerprinted and archived; companion module/context recovered separately.
- Six historical addon work folders have canonical-source AGENTS.md pointers.
- Current task renamed/pinned as FafnyirTools — Main Development; no task content deleted or archived.
- Local Python environment prepared with Lupa 2.8; no remote Git destination configured.

## Checks actually run

The baseline fingerprint check, all 17 Lua 5.1 syntax checks, complete/unique TOC and module contracts, XP behavioral suite, source/aura/options suite, Git whitespace check (excluding original chat formatting), and clean-source packaging passed.

Temporary-copy probes disabled Quest XP, removed Focus application, and dropped Flyout from the TOC. Each produced a failing check as intended; the production source was never changed.

The clean-tree packager generated a ZIP with only the 19 active addon files and verified their hashes. No archived code, transcripts, tests or project metadata entered the addon ZIP.

The final task output includes a source/history snapshot and a Git bundle for portability. It is not an off-machine backup until the user copies it elsewhere. No WoW files were installed and no external release was published.

## Remaining limits

Companion Pet/QoL remains an unresolved historical omission; inventory tracking beyond implemented scanners and Focus aura styling remain incomplete/not implemented. Binary chat attachments are not comprehensively archived. Offline tests do not replace in-game QA. See OPEN_ITEMS.md and TESTING.md.
