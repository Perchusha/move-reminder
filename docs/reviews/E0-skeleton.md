# Review: E0 - Walking skeleton

- Change: E0-skeleton
- Reviewed: c1ad44af742e04abf6ada253749b305bf4cb2505
- Round: 1

## Acceptance criteria

One row per acceptance criterion of the epic, or one row for a bug, its ID: the test that covers it (its file and name) or the QA scenario that checks it. A bug is covered by its regression test, the path in a code span; only where no test can drive the behaviour, by a QA scenario in a file, its path in a code span and `no automated test: <why>` in the same cell.

| Criterion | Covered by |
| --- | --- |
| E0-AC1 | `scripts/gate-selftest`, run by `scripts/gate --full`: case 6 (a badly formatted file fails `scripts/gate --fast` on the format step) and case 7 (the planted test FailsOnPurpose fails `scripts/gate --fast` on the tests step, the same step `--full` runs); `scripts/gate --full` passed at this commit; `.githooks/pre-commit` runs `scripts/gate --fast` |
| E0-AC2 | `.github/workflows/ci.yml`, job `gate` on `windows-latest`: step Gate (`bash scripts/gate --full`), step Build (`scripts/build`, fails without an `ARTIFACT:` line for the .exe) and step Keep the installer (`actions/upload-artifact` with `if-no-files-found: error`) |
| E0-AC3 | `.claude/pitwall.json` records `mergeProtection` as `branch-protection`, written on main by 589f573 (chore: record merge protection) |
| E0-AC4 | `.github/workflows/ci.yml` steps Build and Install and uninstall (`scripts/build` prints both `ARTIFACT:` lines and fails when `git status` differs after the build); the tray icon with «Выход»: QA-E0-1 in `docs/qa/E0-skeleton.md`, as no automated test can drive the tray |
| E0-AC5 | `CLAUDE.md`, Commands; `scripts/gate --full` passed at this commit, and CI runs the gate, `scripts/build` and `scripts/test-installer` |
| E0-AC6 | `scripts/gate-selftest` cases 1 to 5 (RS0030 on each banned line in Core and in App, CS0234 for a WinForms type in Core, NETSDK1136 for UseWindowsForms in Core, MSB4006 for Core referencing App); `tests/MoveReminder.Core.Tests/CoreBoundaryTests.cs`: CoreTargetsPlainNet10WithoutAPlatform and CoreDoesNotReference; `nuget.config` clears every source but nuget.org |
| E0-AC7 | `scripts/test-installer`, run in CI: asInvoker in the manifest, the fixed folder despite /D=, the Start menu shortcut and the HKCU entry, and after the uninstall only a file it did not install left and the settings folder in APPDATA unchanged; QA-E0-1 and QA-E0-2 in `docs/qa/E0-skeleton.md` for the UAC prompt and the pages a person sees |
| E0-AC8 | QA-E0-3 in `docs/qa/E0-skeleton.md`: an hour in the tray on the owner's PC, which no automated test can measure |
| E0-AC9 | `LICENSE` (MIT); `scripts/test-installer`: LICENSE.txt in the install folder is the MIT licence, and THIRD-PARTY-NOTICES.txt names WinRT.Runtime.dll, Microsoft.Windows.SDK.NET.dll, NSIS and the .NET runtime; QA-E0-1 step 7 |

## Findings

Numbered from 1, each kept with its number from round to round. A closed row starts its last cell with the commit on this branch that closes it, or with a risk `R-n` the owner accepted; an open one starts with `open:`.

| # | Finding | Severity (blocking, should fix) | Closed by (commit) or accepted risk |
| --- | --- | --- | --- |
