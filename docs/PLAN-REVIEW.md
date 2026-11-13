# Plan review

Written at stage 5 by the `plan-reviewer` agent, from the documents only; it is the only file the reviewer writes. The main conversation closes findings in the epics, `SPEC.md` and `RISKS.md`, and the next review round records them here. Development starts when every reason and finding is closed or accepted as a risk. A closed row starts its last cell with the ID that closes it (an epic, a criterion, an ADR, or a risk `R-n` the owner accepted); an open one starts with `open:`.

## Pre-mortem

"A year from now the project failed. Why?" As many reasons as pitwall's `preMortemReasons` asks for the process level.

The lite level asks for no pre-mortem (preMortemReasons is 0 for processLevels.lite), so this table stays empty.

| # | Reason | Closed by (epic, ADR) or accepted risk |
| --- | --- | --- |

## Non-functional requirements

One row per item of pitwall's `planReview.nonFunctional` for the process level.

| Requirement | Answer | Where it lives |
| --- | --- | --- |
| Security and secrets | No secrets: no API keys and no network. The app runs without admin rights; System.Net.Http and System.Net.Sockets are banned in both projects by BannedApiAnalyzers, so a network call fails the build; the pitwall hook refuses a commit with a secret | E0-AC6, SPEC.md Non-functional requirements, CLAUDE.md Architecture boundaries |
| Dependency licences | The project is MIT. The installer ships .NET 10 and Windows Forms (MIT) and the NSIS stub (zlib/libpng); the test packages (Apache-2.0, MIT) and BannedApiAnalyzers (MIT) do not ship; Windows App SDK is not used; GPL is not allowed. The Windows SDK projection is missing from the list (finding 3) | ADR-0003, SPEC.md Non-functional requirements, STACK.md Decisions |
| Backups and restore | The only data is settings.json, with no backup. An unreadable file or an unknown schemaVersion is renamed next to it with a timestamp and the app starts with defaults; the uninstaller leaves %APPDATA%\move-reminder in place, so a reinstall keeps the settings. A torn write is not guarded against (finding 10) | E1-AC2, E0-AC7, ADR-0001, SPEC.md Non-functional requirements |
| Performance targets | In the tray with the settings window closed, after an hour: up to 50 MB private working set as Task Manager shows it, and about 0% CPU. A reminder arrives no later than one minute after its due time, which no criterion checks yet (finding 5) | E3-AC7, ADR-0003, SPEC.md Non-functional requirements |

## Launch questions

One row per item of pitwall's `planReview.launch` for the process level, as the owner confirmed it in `SPEC.md`.

| Question | Answer | Confirmed on |
| --- | --- | --- |
| App stores | No store: only the installer in GitHub Releases of the public repository, no Microsoft Store, Steam or winget | 2026-11-13, SPEC.md Launch |
| Support channel | GitHub Issues of the public repository; the README says the app comes without support or warranty and a reply is not guaranteed (E3-AC5) | 2026-11-13, SPEC.md Launch |

## Epic sizing

| Epic | Size (S, M, L) | Uncertainty (known, partly, unknown) | Action |
| --- | --- | --- | --- |
| E0 | M | partly | - |
| E1 | M | known | - |
| E2 | M | partly | - |
| E3 | M | partly | - |

An epic whose size or uncertainty is in pitwall's `planReview.needsAction` has an action: split it, clarify it, or a spike first.

## Findings

Gaps in the plan: a scenario no criterion covers, a criterion QA cannot check, an epic too big for one PR, a risky assumption nothing covers.

| # | Finding | Severity | Closed by (epic, ADR) or accepted risk |
| --- | --- | --- | --- |
| 1 | Scenario «Ежечасное напоминание о движении»: nothing says when a «каждые N минут» reminder fires again if it is neither closed nor snoozed. The scheduler rules in SPEC Architecture and E1-AC3 restart the count only after start, after «Закрыть» and after a pause ends, yet a reply is often impossible: R-1 leaves no buttons in the Action Center, under Do Not Disturb the notification goes there without a banner (spike, 1 of 1), and a banner can time out or be swiped away. Read literally, the hourly reminder stops after the first unanswered one, and no test or QA step would show it | blocking | open: a scheduler rule in SPEC for an unanswered reminder (for example, the next N minutes count from the moment it was shown) with an E1 criterion tested on FakeTimeProvider, and an E2 criterion where QA leaves a notification unanswered and the next one still arrives |
| 2 | ADR-0002 left to the A-1 spike how the AppUserModelID is registered (on the Start menu shortcut by NSIS, or by app code) and promises that the uninstaller removes the notification registration. docs/spikes/toast-buttons.md does not record what the prototype did, and no criterion requires the registration or its removal: E0-AC7 asks only for a shortcut, E2-AC7 only for the autostart key | should fix | open: an E0 or E2 criterion that names the mechanism the prototype used, and that the uninstaller removes the registration |
| 3 | E0-AC6 and SPEC Architecture give MoveReminder.App the target net10.0-windows, but Windows.UI.Notifications is reachable from .NET only with a versioned target such as net10.0-windows10.0.19041.0. That target also puts the Windows SDK projection (Microsoft.Windows.SDK.NET.dll, WinRT.Runtime.dll) into the self-contained installer, and the Dependency licences line of SPEC, which lists only .NET, Windows Forms and NSIS, leaves it out | should fix | open: E0-AC6 names the versioned target the prototype used, and SPEC Non-functional requirements (Dependency licences) lists the projection assemblies with their licence |
| 4 | A-4 and the 50 MB threshold of ADR-0003, a one-way decision taken with no measurement, are first measured in E3-AC7, the last epic, after E1 and E2 are built on the stack; a miss there leaves no cheap way back | should fix | open: a criterion in E0 (the tray app of E0-AC4) or E2 (with notifications loaded) that records its private working set against the 50 MB threshold, so a miss shows before the product is built |
| 5 | SPEC Performance targets promise a reminder no later than one minute after its due time, but no criterion checks it: E2-AC1 and E2-AC4 say only that the notification comes, and E1 tests run on fake time | should fix | open: E2-AC1 and E2-AC4 say the notification arrives within one minute of its due time, as QA measures it |
| 6 | Updates are not planned. With autostart the app runs in the tray all day, so every new version installs over a running one with its files locked. A-5 names this check (install the next version over the old one: it starts by itself, settings in place), but no criterion covers it, nor says that a user who turned autostart off keeps it off after an update, while E2-AC7 turns it on at first run | should fix | open: an E0, E2 or E3 criterion: the installer closes the running app or asks to, installs over it, and settings.json and the autostart choice survive |
| 7 | E0-AC7 asks the uninstaller to remove the app, but not to remove only what the installer put there. An NSIS uninstaller that deletes the install folder recursively also deletes the user's files when the user chose an existing folder, a data deletion the normal risk class of E0 does not expect | should fix | open: E0-AC7 says the app installs into a fixed folder in the user's profile with no folder choice, or that the uninstaller deletes only the files it installed |
| 8 | ADR-0002 decides that the installer is built on a GitHub Actions Windows runner and published to GitHub Releases, with the local build as lite staging; E0-AC4 makes the local build the release and E0-AC2 runs only the gate in CI, so no epic builds the installer on the runner | should fix | open: E0-AC2 has CI also run scripts/build, so the installer ADR-0002 describes is built on the runner |
| 9 | The tray menu in SPEC Architecture (Отложить, Пауза на час, Пауза до конца дня, Снять паузу, Настройки, Выход) lacks the «Автозапуск» item that E2-AC3 and E2-AC7 add | should fix | open: SPEC Architecture lists the same menu as E2-AC3 |
| 10 | Saving settings.json is not required to survive a crash or a power loss mid-write. E1-AC2 then sets the torn file aside and the app starts with defaults, so the user's own reminders from E3 vanish from the app; SPEC Backups and restore rests on that one file | should fix | open: an E1 criterion that settings.json is written to a temporary file and replaced in one step, with a test |

## Approval

Filled in by the first commit of E0's branch, from the plan's merge commit: who approved the plan, when, and the merge commit.
