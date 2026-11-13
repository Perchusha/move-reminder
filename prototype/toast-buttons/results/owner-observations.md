# Owner observations, 2026-11-13

Reported by the owner in the session while measuring by hand.

- Windows notifications were off for the whole user before the test (HKCU PushNotifications ToastEnabled = 0; the notifier reported DisabledForUser). The owner turned them on for the test. The first delivery run, with notifications still off, failed with 0x803E0114 on all 10 toasts; the second run delivered 10 of 10.
- Installer: 0 UAC prompts.
- Delivery step: the owner saw one banner that vanished at once; by design the prototype removes the delivery toasts a second after showing them.
- Banners: the owner pressed "Otlozhit" (snooze) on all five banners, including 4 and 5, which asked for "Zakryt" (dismiss). All five clicks reached the app as snooze. The dismiss button was not exercised.
- Notification center (Win+N): the five toasts there showed no buttons at all. Four were closed by the owner (Dismissed, UserCanceled); one body click (a4) reached the app.
- Do not disturb on: no banner appeared, the toast was in the Win+N list, and the history count was 1 of 1.
