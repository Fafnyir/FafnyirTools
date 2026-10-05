# Fafnyir Tools for EllesmereUI

A collection of enhancements for EllesmereUI.

**Authoritative local project:** `/Users/fpatten/Documents/Codex/FafnyirTools`

**Current source:** v1.1.9 native XP gradient cleanup based on the user-confirmed
v1.1.4 build `1aae4fe`. Prior confirmed ZIPs remain immutable under releases/.

WoW Forever beta compatibility development lives on the `forever-beta` branch.
It preserves Retail v1.1.3 behavior and adds guarded interface 16001 support.
See [Forever compatibility](docs/FOREVER_COMPAT.md).

## Start here

- [Current state](docs/CURRENT_STATE.md): what is working and what was actually verified.
- [Feature requirements](docs/FEATURES.md): requirements every future change must preserve.
- [Decisions](docs/DECISIONS.md): resolved conflicts and discarded experiments.
- [Open items](docs/OPEN_ITEMS.md): omissions/proposals that must not be mistaken for shipped features.
- [History index](docs/HISTORY.md): consolidated chat records and earlier builds.
- [Manual test checklist](docs/TESTING.md): runtime checks that mocks cannot perform.
- [Changelog](CHANGELOG.md): reconciled release history.

## Development

### GitHub releases

The private repository includes a manually triggered **Build GitHub Release**
workflow. In GitHub, open **Actions**, select that workflow, and choose **Run
workflow** on the commit or branch to release. Enter the exact version from
`FafnyirTools.toc` and choose Draft, Prerelease, or Final. Draft is the default.

The workflow runs the complete offline test suite, packages only the canonical
`src/FafnyirTools` source, verifies the ZIP, creates `release/<version>`, and
uploads both the revision-stamped ZIP and its build manifest. It refuses to
reuse an existing version tag. In-game testing remains a manual release gate.

Draft releases remain on GitHub only. Prerelease runs upload the same ZIP to
CurseForge project `1640881` as a Beta, while Final runs upload it as a Release.
CurseForge authentication is stored in the `CURSEFORGE_API_TOKEN` repository
secret. The upload declares the Retail and Forever versions supported by the
TOC and explicitly preserves the revision-stamped ZIP filename; update the
workflow version list when support changes.

The existing task is now pinned as **FafnyirTools — Main Development** (ID `01a04568-9348-7180-8adf-921ebcbdd3b7`). Its content is retained; other tasks were not renamed or archived.

Open/add **this folder** as a project in Codex. There are no saved app projects at consolidation time; creating this repository does not automatically add an app project or move existing tasks. In any existing task, explicitly point it at this path and ask it to read AGENTS.md before edits. That file applies when the agent works in this repository; it is not global memory for unrelated chats.

Suggested starting prompt:

> Work in /Users/fpatten/Documents/Codex/FafnyirTools. Read AGENTS.md and docs/CURRENT_STATE.md, inspect Git status, and use src/FafnyirTools as the only source. Preserve the documented features and saved settings. Do not start from a historical ZIP.

For a fresh checkout:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-dev.txt
.venv/bin/python tools/check.py
```

A local `.venv` has been prepared on this Mac using the previously installed Lupa runtime. The virtual environment is not committed or included in portable project snapshots. Lupa supplies an actual Lua 5.1 interpreter for syntax and mocked runtime tests; WoW/EllesmereUI are not emulated in full.

After an authorized change, update the records, review and commit, then:

```sh
.venv/bin/python tools/package.py
```

The package is written under ignored `dist/`, includes only `FafnyirTools/`, and carries a Git revision in its filename. A separate build manifest records the revision and hashes. The current Retail and Forever version is v1.1.9.

## Installation

Install EllesmereUI and FafnyirMedia first, then install a packaged ZIP by replacing the `FafnyirTools` folder under WoW's `Interface/AddOns` and reload. Do not delete SavedVariables. This consolidation does not install files into WoW and does not modify either dependency.

## History and privacy

All prior tasks remain intact. The local history is a dated reference snapshot, not live synchronization or a literal merge of chats. It contains user/assistant project discussions; do not publish the repository or its history without reviewing it. No remote repository is configured. Media attachments are not comprehensively mirrored.

2026-10-03 filename correction: use the exact packaged ZIP basename
`Fafnyir_Tools_for_EllesmereUI_(version)_(commit).zip` for GitHub release titles
and CurseForge display names as well as uploaded filenames. The former friendly
display name obscured the correctly named artifact. The repair workflow changes
only existing release metadata; it does not rebuild or replace ZIPs.
