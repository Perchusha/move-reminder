# Epics

The plan: epics in order, no dates. Each epic is one PR with a testable result and has its own file in `epics/`.

| Epic | Goal | Risk | Depends on | Status |
| --- | --- | --- | --- | --- |
| [E0](epics/E0-skeleton.md) | Walking skeleton: gate, CI, merge protection, the release build, staging at the standard and full levels | normal | decisions in `adr/` | planned |
| [E1](epics/E1-core.md) | Ядро: модель напоминаний, settings.json и планировщик, проверенный тестами на фейковом времени | normal | E0 | planned |
| [E2](epics/E2-tray-app.md) | Приложение в трее: уведомления с кнопками, меню, сон и блокировка, предупреждение о выключенных уведомлениях, автозапуск | normal | E1 | planned |
| [E3](epics/E3-settings-and-release.md) | Окно настроек, README про установку без подписи, проверка установки и памяти | normal | E2 | planned |

Status: planned, in progress, in review, merged, released.
