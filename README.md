# Fafnyir Tools for EllesmereUI

A collection of enhancements for EllesmereUI.

**Authoritative local project:** `/Users/fpatten/Documents/Codex/FafnyirTools`

**Current baseline:** v1.1.2 QuestXPFixed, confirmed working by the user on 2026-08-27. This consolidation changes no addon files. The exact 19-file source is in `src/FafnyirTools`; the original corrected ZIP is in `releases/`.

## Start here

- [Current state](docs/CURRENT_STATE.md): what is working and what was actually verified.
- [Feature requirements](docs/FEATURES.md): requirements every future change must preserve.
- [Decisions](docs/DECISIONS.md): resolved conflicts and discarded experiments.
- [Open items](docs/OPEN_ITEMS.md): omissions/proposals that must not be mistaken for shipped features.
- [History index](docs/HISTORY.md): consolidated chat records and earlier builds.
- [Manual test checklist](docs/TESTING.md): runtime checks that mocks cannot perform.
- [Changelog](CHANGELOG.md): reconciled release history.

## Development

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

The package is written under ignored `dist/`, includes only `FafnyirTools/`, and carries a Git revision in its filename. A separate build manifest records the revision and hashes. Keep using v1.1.2 until a version change is requested.

## Installation

Install a packaged ZIP by replacing the `FafnyirTools` folder under WoW's `Interface/AddOns`, then reload. Do not delete SavedVariables. This consolidation does not install files into WoW and does not modify EllesmereUI.

## History and privacy

All prior tasks remain intact. The local history is a dated reference snapshot, not live synchronization or a literal merge of chats. It contains user/assistant project discussions; do not publish the repository or its history without reviewing it. No remote repository is configured. Media attachments are not comprehensively mirrored.
