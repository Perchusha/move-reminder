# ADR-0003: Фреймворк: Windows Forms на .NET 10 LTS (C#)

- Status: accepted
- Date: 2026-11-13
- Class: one-way
- Decided by: owner

## Context

Этот выбор задаёт язык, рантайм и весь код приложения: трей, уведомления, окно настроек, реакцию на сон и блокировку, автозапуск. Владелец хочет стек легче Electron (A-4); кроме того, неподписанное неупакованное приложение должно показывать уведомления с кнопками (A-1), узнавать о сне и блокировке (A-3) и включать автозапуск без прав администратора (A-5). Платформа только Windows 11 x64, бюджет 0, лицензия проекта MIT, телеметрии нет (docs/DISCOVERY.md).

## Options

| Option | Pros | Cons | Maturity | Cost | Lock-in | Source |
| --- | --- | --- | --- | --- | --- | --- |
| Windows Forms на .NET 10 LTS (C#) | Нет браузерного движка в процессе; трей встроен (NotifyIcon); сон и блокировка встроены (SystemEvents.PowerModeChanged, SessionSwitch); уведомления с кнопками через Windows App SDK, где для неупакованного приложения Register() сам настраивает COM и AUMID; WinForms под MIT | Кнопки идут через Windows App SDK с проприетарной лицензией и пунктом о возможном сборе данных (непроверенная альтернатива: встроенный WinRT ToastNotificationManager); trimming и Native AOT для WinForms нет, self-contained сборка крупная (размер unknown); простой UI; замера памяти нет | .NET 10.0.15 от 2026-11-10, поддержка до 2028-11-14; Microsoft.WindowsAppSDK 2.6.5 от 2026-11-03 | 0 | Только Windows; UI на WinForms не переносится | https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/app-notifications-dotnet |
| Tauri 2 (Rust и системный WebView2, UI на TypeScript) | Трей встроен; автозапуск через плагин в HKCU Run без прав администратора; кнопки в уведомлении через crate tauri-winrt-notification; MIT или Apache-2.0 | Официальный плагин уведомлений не умеет кнопки на десктопе; событий сна и блокировки нет, нужен свой Win32-код; замер пустого приложения с окном (Elanis, без даты и версий) около 312 МБ против около 279 МБ у Electron; два языка | Tauri 2.12.5 от 2026-10-21; уже есть 3.0.0-alpha | 0 | Средний: ядро на Rust завязано на API Tauri | https://v2.tauri.app/plugin/notification/ |
| Electron (TypeScript) | Всё встроено: кнопки в уведомлениях на Windows, powerMonitor (suspend, resume, lock), трей, setLoginItemSettings; самый зрелый | Противоречит пожеланию владельца «легче Electron»; в том же замере около 279 МБ; нужен ярлык с AUMID | Electron 45.3.2 от 2026-11-13 | 0 | От низкого до среднего: main и renderer, IPC завязаны на API Electron | https://www.electronjs.org/docs/latest/api/structures/notification-action |
| Wails v3 (Go и WebView2) | Заявлены трей, уведомления с кнопками через wintoast, события сна; MIT | Стабильной ветке v3 около трёх недель; кнопки на Windows подтверждены только в документации v2; блокировка экрана на Windows не подтверждена; в замере около 330 МБ с окном; не проходит правило new but proven | v3.1.0 от 2026-11-01 | 0 | Средний: бэкенд на Go завязан на сервисы Wails | https://github.com/wailsapp/wails/releases/tag/v3.0.0 |

## Decision

Windows Forms на .NET 10 LTS, язык C#. Платформа и рантайм: Windows 11 x64, приложение публикуется self-contained (рантайм .NET едет внутри установщика из ADR-0002, отдельно ставить ничего не нужно). Владелец выбрал рекомендацию: это единственный вариант без браузерного движка, и у трея, сна и блокировки, автозапуска есть путь из документации Microsoft. Для A-3 это SystemEvents.PowerModeChanged и SessionSwitch, для A-5 ключ HKCU Run без прав администратора; оба проверяются в эпиках прототипом и ручным QA. Для A-4 решение даёт стек без браузерного движка, а порог владелец задал 2026-11-13: до 50 МБ памяти по Диспетчеру задач и около 0% CPU в трее с закрытым окном настроек после часа работы.

## Consequences

- Уведомления с кнопками проверяет спайк. Первым пробуется встроенный WinRT ToastNotificationManager без Windows App SDK: приложение в трее работает всегда, так что нажатия можно ловить в процессе. Если без SDK кнопки не работают, лицензию Windows App SDK (проприетарная, с пунктом о возможном сборе данных) владелец принимает или отклоняет отдельно, через /pitwall:decide Framework или принятый риск.
- Окно настроек на стандартных контролах WinForms: просто, без веб-интерфейса.
- Trimming и Native AOT для WinForms недоступны, поэтому установщик крупнее, чем у нативного приложения; точный размер покажет первая сборка.
- Tauri, Electron и Wails остаются в истории как сравнённые варианты. Wails v3 не проходил правило new but proven.
- Пересмотр: смена фреймворка означает переписать приложение. Дёшево до первого эпика с кодом; если спайк провалится, область пересматривается через /pitwall:decide Framework.
