# QA scenarios: E0 walking skeleton

The checks of [E0](../epics/E0-skeleton.md) that no automated test can drive: a tray icon, a UAC prompt a person would see, an hour of memory use. Everything else is automated: `scripts/gate --full` (E0-AC1, E0-AC6), CI (E0-AC2), `scripts/build` (E0-AC4) and `scripts/test-installer` (E0-AC7, E0-AC9; and that the installer, `MoveReminder.exe`, `Uninstall.exe` and the shortcut carry the app's icon). What no script can see is whether the icon is visible in the tray: that is QA-E0-1, step 4.

Before you start: build the installer with `scripts/build 0.0.1` in Git Bash. It prints `ARTIFACT: artifacts/0.0.1/move-reminder-setup-0.0.1.exe`. The same installer comes out of CI as the workflow artifact `move-reminder-setup`. An installer built before the app had its own icon shows none: if one is installed, uninstall it first (QA-E0-2) and build again from the branch as it is now.

## QA-E0-1: install without UAC, and the app's icon in the tray (E0-AC4, E0-AC7)

1. In Explorer, look at `move-reminder-setup-0.0.1.exe` before you run it. Expected: its icon is the app's own, a white arrow pointing up on a green rounded square, not the NSIS default.
2. Double-click `move-reminder-setup-0.0.1.exe`. If SmartScreen warns about an unknown publisher, choose «Подробнее», then «Выполнить в любом случае» (ADR-0002).
3. Expected: no UAC prompt (the screen does not dim and Windows does not ask for administrator rights), and no page that asks for a folder. The installer shows its progress page in Russian and finishes with «Готово».
4. Close the installer. Expected: the app has started by itself, and its icon is in the tray (it can be under the ^ arrow of the hidden icons): the white arrow on the green square, clearly visible and sharp, never an empty place or a blank window frame. If you can, look at it on both the light and the dark taskbar (Settings, Personalization, Colors) and at the display scaling you use. Its tooltip reads `move-reminder`.
5. Right-click the icon. Expected: a menu with one item, «Выход».
6. Click «Выход». Expected: the icon disappears, and Task Manager has no `MoveReminder.exe` left.
7. Open the Start menu and type `move-reminder`. Expected: the shortcut is there with the same icon, and it starts the app with its tray icon again.
8. Open `%LOCALAPPDATA%\Programs\move-reminder` in Explorer. Expected: `MoveReminder.exe`, `LICENSE.txt`, `THIRD-PARTY-NOTICES.txt` and `Uninstall.exe` are there (E0-AC9), and `MoveReminder.exe` and `Uninstall.exe` show the same icon; so does `move-reminder` in Settings, Apps, Installed apps.

## QA-E0-2: uninstall (E0-AC7)

1. Click «Выход» in the tray menu if the app is running.
2. Open Settings, Apps, Installed apps, find `move-reminder` and choose «Удалить».
3. Expected: no UAC prompt; the uninstaller asks to confirm in Russian, then removes the app.
4. Expected: `%LOCALAPPDATA%\Programs\move-reminder` is gone (or, if you put a file of your own there, only that file is left), the Start menu has no `move-reminder` shortcut, and `%APPDATA%\move-reminder`, if it was there before, is still there with everything in it.

## QA-E0-3: an hour in the tray (E0-AC8, the baseline for A-4)

1. Install as in QA-E0-1 and start the app from the Start menu. Open nothing else of it.
2. Leave the computer awake, unlocked or locked, for one hour.
3. Open Task Manager, the «Процессы» tab, and find `MoveReminder` (or `move-reminder`). Note the «Память» column (the private working set) and the «ЦП» column.
4. Or, in PowerShell, read the same numbers five times a minute apart:

   ```powershell
   Get-Counter "\Process(MoveReminder)\Working Set - Private","\Process(MoveReminder)\% Processor Time" -SampleInterval 60 -MaxSamples 5
   ```

   The working set comes in bytes; divide by 1048576 for MB.
5. Expected: memory at most 50 MB, CPU about 0%. The numbers go into `docs/JOURNAL.md` as the baseline for A-4.

A reading from the agent's session, for comparison only: the published app, 30 seconds after start on the owner's PC (Windows 11 Pro 10.0.26300), used 6.3 MB of private working set and 0.0% CPU (2026-11-13).
