# E0 - Walking skeleton

Goal: the empty project builds, tests and reaches staging, or a local build at the lite level, so every later epic runs the full loop from its first day.
Depends on: the stack decisions in `docs/adr/`
Risk class: normal
ADR: ADR-0002, ADR-0003

## Acceptance criteria

- [ ] E0-AC1: `scripts/gate --full` runs the real checks for the chosen stack (`dotnet format --verify-no-changes`, a build with warnings as errors, the tests) and exits non-zero when a test fails; `scripts/gate --fast` runs the quick ones in seconds, since `.githooks/pre-commit` runs it before every commit.
- [ ] E0-AC2: CI runs the gate on every PR as the check named `gate`, on a `windows-latest` runner, and also runs `scripts/build` there and keeps the installer it prints as a workflow artifact (ADR-0002).
- [ ] E0-AC3: Merge protection is on: `.claude/pitwall.json` records `branch-protection` or `local-hook`, not `pending`, and pitwall's `protect.mjs` confirms it.
- [ ] E0-AC4: `scripts/build <version>` builds the "hello world" app from the tree as it is (a self-contained publish for win-x64 and an unsigned per-user NSIS installer), changes no tracked file, and prints one `ARTIFACT: <path>` line for each thing it built; the installed app runs and shows a tray icon with an «Выход» item. At the lite level this local build is the release.
- [ ] E0-AC5: `CLAUDE.md` lists the real commands, each run successfully.
- [ ] E0-AC6: The solution holds `src/MoveReminder.Core` (`net10.0`), `src/MoveReminder.App` (`net10.0-windows10.0.19041.0`, the target the spike prototype used) and `tests/MoveReminder.Core.Tests`, with a repository `nuget.config` that names nuget.org; a reference to WinForms from Core, or `DateTime.Now`, `HttpClient` or a socket type in either project, fails the build (CLAUDE.md, Architecture boundaries).
- [ ] E0-AC7: The installer installs without a UAC prompt into the fixed folder `%LOCALAPPDATA%\Programs\move-reminder`, offers no choice of folder, and adds a Start menu shortcut; its uninstaller deletes only the files the installer put there and the shortcut, and leaves `%APPDATA%\move-reminder` in place.
- [ ] E0-AC8: The installed "hello world" app, left in the tray for an hour, uses at most 50 MB of private working set (the Memory column of Task Manager) and about 0% CPU; the measured numbers are recorded in `docs/JOURNAL.md` as the baseline for A-4.

## Out of scope

Any product feature: reminders, notifications, settings, autostart.

## Open questions

None.
